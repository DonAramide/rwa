#!/usr/bin/env node

const { createLibp2p } = require('libp2p');
const { tcp } = require('@libp2p/tcp');
const { noise } = require('@libp2p/noise');
const { mplex } = require('@libp2p/mplex');
const { bootstrap } = require('@libp2p/bootstrap');
const { kadDHT } = require('@libp2p/kad-dht');
const { gossipsub } = require('@libp2p/gossipsub');
const express = require('express');
const winston = require('winston');
const cron = require('node-cron');
const { ethers } = require('ethers');

require('dotenv').config();

// Configure logging
const logger = winston.createLogger({
  level: 'info',
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.json()
  ),
  transports: [
    new winston.transports.Console(),
    new winston.transports.File({ filename: '/data/validator/logs/validator.log' })
  ]
});

class RWAValidatorNode {
  constructor() {
    this.nodeId = process.env.VALIDATOR_ID || 'validator-unknown';
    this.stakeAmount = parseInt(process.env.STAKE_AMOUNT) || 1000;
    this.libp2p = null;
    this.blockchain = null;
    this.consensus = new ConsensusEngine();
    this.reputation = new ReputationSystem();
    this.metrics = new MetricsCollector();
    this.isBootstrapped = false;
  }

  async initialize() {
    logger.info(`Initializing RWA Validator Node: ${this.nodeId}`);

    try {
      // Initialize libp2p node
      await this.setupLibp2p();
      
      // Initialize blockchain connection
      await this.setupBlockchain();
      
      // Start consensus participation
      await this.startConsensus();
      
      // Start metrics collection
      await this.startMetrics();
      
      // Start HTTP API
      await this.startAPI();
      
      // Schedule periodic tasks
      this.scheduleTasks();
      
      logger.info(`Validator node ${this.nodeId} initialized successfully`);
      
    } catch (error) {
      logger.error('Failed to initialize validator node:', error);
      process.exit(1);
    }
  }

  async setupLibp2p() {
    const bootstrapPeers = process.env.BOOTSTRAP_PEERS?.split(',') || [];
    
    this.libp2p = await createLibp2p({
      addresses: {
        listen: ['/ip4/0.0.0.0/tcp/4001']
      },
      transports: [tcp()],
      streamMuxers: [mplex()],
      connectionEncryption: [noise()],
      peerDiscovery: bootstrapPeers.length > 0 ? [
        bootstrap({
          list: bootstrapPeers
        })
      ] : [],
      dht: kadDHT({
        kBucketSize: 20,
        clientMode: false
      }),
      pubsub: gossipsub({
        allowPublishToZeroPeers: true,
        msgIdFn: (msg) => {
          return ethers.utils.keccak256(msg.data);
        }
      }),
      connectionManager: {
        maxConnections: 100,
        minConnections: 10
      }
    });

    // Set up event handlers
    this.setupLibp2pEvents();
    
    await this.libp2p.start();
    logger.info(`libp2p node started with peer ID: ${this.libp2p.peerId.toString()}`);
  }

  setupLibp2pEvents() {
    this.libp2p.addEventListener('peer:connect', (event) => {
      logger.info(`Connected to peer: ${event.detail.toString()}`);
      this.metrics.incrementPeerCount();
    });

    this.libp2p.addEventListener('peer:disconnect', (event) => {
      logger.info(`Disconnected from peer: ${event.detail.toString()}`);
      this.metrics.decrementPeerCount();
    });

    // Subscribe to consensus topics
    this.libp2p.pubsub.subscribe('rwa:consensus:proposals');
    this.libp2p.pubsub.subscribe('rwa:consensus:votes');
    this.libp2p.pubsub.subscribe('rwa:verification:reports');
    
    this.libp2p.pubsub.addEventListener('message', this.handlePubsubMessage.bind(this));
  }

  async handlePubsubMessage(event) {
    const { topic, data } = event.detail;
    
    try {
      const message = JSON.parse(new TextDecoder().decode(data));
      
      switch (topic) {
        case 'rwa:consensus:proposals':
          await this.handleConsensusProposal(message);
          break;
        case 'rwa:consensus:votes':
          await this.handleConsensusVote(message);
          break;
        case 'rwa:verification:reports':
          await this.handleVerificationReport(message);
          break;
      }
    } catch (error) {
      logger.error(`Error handling pubsub message for topic ${topic}:`, error);
    }
  }

  async setupBlockchain() {
    const rpcUrl = process.env.RPC_URL || 'http://localhost:8545';
    const privateKey = process.env.PRIVATE_KEY;
    
    if (!privateKey) {
      throw new Error('PRIVATE_KEY environment variable required');
    }
    
    this.blockchain = new ethers.JsonRpcProvider(rpcUrl);
    this.wallet = new ethers.Wallet(privateKey, this.blockchain);
    
    // Load smart contracts
    await this.loadContracts();
    
    logger.info(`Connected to blockchain at ${rpcUrl}`);
  }

  async loadContracts() {
    // Load contract ABIs and addresses
    const contracts = {
      registry: process.env.REGISTRY_CONTRACT,
      token: process.env.TOKEN_CONTRACT,
      distribution: process.env.DISTRIBUTION_CONTRACT
    };
    
    this.contracts = {};
    
    for (const [name, address] of Object.entries(contracts)) {
      if (address) {
        // Load ABI from file or environment
        const abi = require(`../config/abi/${name}.json`);
        this.contracts[name] = new ethers.Contract(address, abi, this.wallet);
      }
    }
  }

  async startConsensus() {
    // Register as validator on-chain
    await this.registerValidator();
    
    // Start consensus round timer
    this.startConsensusRounds();
    
    logger.info('Consensus participation started');
  }

  async registerValidator() {
    try {
      if (this.contracts.registry) {
        const tx = await this.contracts.registry.registerValidator(
          this.stakeAmount,
          { value: ethers.parseEther(this.stakeAmount.toString()) }
        );
        await tx.wait();
        logger.info(`Registered as validator with stake: ${this.stakeAmount}`);
      }
    } catch (error) {
      logger.error('Failed to register as validator:', error);
    }
  }

  startConsensusRounds() {
    // Consensus round every 30 seconds
    setInterval(async () => {
      await this.participateInConsensus();
    }, 30000);
  }

  async participateInConsensus() {
    try {
      // Check for pending verification reports
      const pendingReports = await this.getPendingReports();
      
      for (const report of pendingReports) {
        await this.validateReport(report);
      }
    } catch (error) {
      logger.error('Error in consensus participation:', error);
    }
  }

  async handleConsensusProposal(proposal) {
    logger.info(`Received consensus proposal: ${proposal.id}`);
    
    // Validate proposal
    const isValid = await this.consensus.validateProposal(proposal);
    
    if (isValid) {
      // Create and broadcast vote
      const vote = await this.consensus.createVote(proposal, true);
      await this.broadcastVote(vote);
    }
  }

  async handleVerificationReport(report) {
    logger.info(`Received verification report: ${report.id}`);
    
    // Validate report structure and signatures
    const validation = await this.validateVerificationReport(report);
    
    if (validation.isValid) {
      // Update reputation of reporting agent
      await this.reputation.updateAgentReputation(
        report.agentId, 
        validation.score
      );
      
      // Broadcast validation result
      await this.broadcastValidation(report.id, validation);
    }
  }

  async validateVerificationReport(report) {
    // Implement comprehensive validation logic
    const checks = {
      structure: this.validateReportStructure(report),
      signatures: await this.validateSignatures(report),
      content: await this.validateContent(report),
      geoLocation: await this.validateGeoLocation(report),
      timestamps: this.validateTimestamps(report)
    };
    
    const score = Object.values(checks).reduce((sum, check) => 
      sum + (check ? 1 : 0), 0) / Object.keys(checks).length;
    
    return {
      isValid: score >= 0.8,
      score,
      checks
    };
  }

  async startAPI() {
    const app = express();
    app.use(express.json());
    
    // Health check endpoint
    app.get('/health', (req, res) => {
      res.json({
        status: 'healthy',
        nodeId: this.nodeId,
        peers: this.libp2p.getPeers().length,
        uptime: process.uptime()
      });
    });
    
    // Metrics endpoint
    app.get('/metrics', (req, res) => {
      res.json(this.metrics.getMetrics());
    });
    
    // Node info endpoint
    app.get('/info', (req, res) => {
      res.json({
        nodeId: this.nodeId,
        peerId: this.libp2p.peerId.toString(),
        stakeAmount: this.stakeAmount,
        reputation: this.reputation.getValidatorReputation(this.nodeId)
      });
    });
    
    const port = process.env.API_PORT || 8080;
    app.listen(port, () => {
      logger.info(`HTTP API listening on port ${port}`);
    });
  }

  scheduleTasks() {
    // Cleanup old data every hour
    cron.schedule('0 * * * *', async () => {
      await this.cleanupOldData();
    });
    
    // Update reputation scores every 10 minutes
    cron.schedule('*/10 * * * *', async () => {
      await this.reputation.updateScores();
    });
    
    // Check stake and slash conditions every 5 minutes
    cron.schedule('*/5 * * * *', async () => {
      await this.checkSlashingConditions();
    });
  }

  async getPendingReports() {
    // Fetch pending reports from network or blockchain
    return [];
  }

  async broadcastVote(vote) {
    await this.libp2p.pubsub.publish(
      'rwa:consensus:votes',
      new TextEncoder().encode(JSON.stringify(vote))
    );
  }

  async broadcastValidation(reportId, validation) {
    await this.libp2p.pubsub.publish(
      'rwa:validation:results',
      new TextEncoder().encode(JSON.stringify({ reportId, validation }))
    );
  }

  validateReportStructure(report) {
    const requiredFields = ['id', 'agentId', 'assetId', 'timestamp', 'data'];
    return requiredFields.every(field => report[field] !== undefined);
  }

  async validateSignatures(report) {
    // Implement signature validation logic
    return true;
  }

  async validateContent(report) {
    // Implement content validation logic
    return true;
  }

  async validateGeoLocation(report) {
    // Implement geo-location validation logic
    return true;
  }

  validateTimestamps(report) {
    const now = Date.now();
    const reportTime = new Date(report.timestamp).getTime();
    const maxAge = 24 * 60 * 60 * 1000; // 24 hours
    
    return (now - reportTime) <= maxAge;
  }

  async cleanupOldData() {
    logger.info('Cleaning up old data...');
    // Implement cleanup logic
  }

  async checkSlashingConditions() {
    // Check for slashing conditions and report if necessary
  }
}

// Consensus Engine
class ConsensusEngine {
  async validateProposal(proposal) {
    // Implement proposal validation logic
    return true;
  }

  async createVote(proposal, approve) {
    return {
      proposalId: proposal.id,
      voter: process.env.VALIDATOR_ID,
      vote: approve,
      timestamp: Date.now(),
      signature: 'signature_placeholder'
    };
  }
}

// Reputation System
class ReputationSystem {
  constructor() {
    this.agentReputations = new Map();
    this.validatorReputations = new Map();
  }

  async updateAgentReputation(agentId, score) {
    const current = this.agentReputations.get(agentId) || { score: 1000, reports: 0 };
    const newScore = (current.score * current.reports + score * 1000) / (current.reports + 1);
    
    this.agentReputations.set(agentId, {
      score: newScore,
      reports: current.reports + 1
    });
  }

  getValidatorReputation(validatorId) {
    return this.validatorReputations.get(validatorId) || { score: 1000, validations: 0 };
  }

  async updateScores() {
    // Implement reputation score updates
  }
}

// Metrics Collector
class MetricsCollector {
  constructor() {
    this.metrics = {
      peerCount: 0,
      consensusRounds: 0,
      validationsPerformed: 0,
      uptime: Date.now()
    };
  }

  incrementPeerCount() {
    this.metrics.peerCount++;
  }

  decrementPeerCount() {
    this.metrics.peerCount--;
  }

  getMetrics() {
    return {
      ...this.metrics,
      uptimeSeconds: Math.floor((Date.now() - this.metrics.uptime) / 1000)
    };
  }
}

// Start the validator node
async function main() {
  const validator = new RWAValidatorNode();
  
  // Graceful shutdown
  process.on('SIGINT', async () => {
    logger.info('Shutting down validator node...');
    if (validator.libp2p) {
      await validator.libp2p.stop();
    }
    process.exit(0);
  });
  
  await validator.initialize();
}

if (require.main === module) {
  main().catch(console.error);
}

module.exports = RWAValidatorNode;