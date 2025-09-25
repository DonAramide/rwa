# RWA Platform P2P Consensus Mechanisms

## 🎯 Overview

This document defines the consensus mechanisms for the RWA Platform's peer-to-peer network, ensuring decentralized validation, verification, and governance.

## 🏛️ Multi-Layer Consensus Architecture

### Layer 1: Asset Verification Consensus
**Purpose**: Validate agent verification reports and asset data
**Mechanism**: Delegated Proof-of-Stake with Reputation (DPoS-R)

```javascript
class AssetVerificationConsensus {
  constructor() {
    this.stakingThreshold = 1000; // RWA tokens
    this.consensusThreshold = 0.66; // 66% agreement required
    this.slashingRate = 0.1; // 10% stake slashed for malicious behavior
  }

  async proposeVerification(reportHash, agentId, assetId) {
    const proposal = {
      id: generateProposalId(),
      type: 'ASSET_VERIFICATION',
      reportHash,
      agentId,
      assetId,
      proposer: this.nodeId,
      timestamp: Date.now(),
      stake: this.currentStake
    };

    // Broadcast to network
    await this.broadcastProposal(proposal);
    
    // Start voting period (5 minutes)
    setTimeout(() => this.finalizeProposal(proposal.id), 300000);
    
    return proposal.id;
  }

  async vote(proposalId, approve, evidence = {}) {
    const vote = {
      proposalId,
      voter: this.nodeId,
      vote: approve,
      weight: this.calculateVotingWeight(),
      evidence,
      timestamp: Date.now(),
      signature: await this.signVote(proposalId, approve)
    };

    await this.submitVote(vote);
    return vote;
  }

  calculateVotingWeight() {
    return Math.sqrt(this.currentStake) * this.reputationScore;
  }
}
```

### Layer 2: Oracle Data Consensus
**Purpose**: Aggregate and validate IoT and external data feeds
**Mechanism**: Weighted Byzantine Fault Tolerance (wBFT)

```javascript
class OracleConsensus {
  constructor() {
    this.byzantineTolerance = 0.33; // Tolerate up to 33% malicious nodes
    this.dataDeviationThreshold = 0.05; // 5% max deviation
    this.aggregationWindow = 300; // 5-minute windows
  }

  async aggregateDataFeed(assetId, dataType) {
    const readings = await this.collectReadings(assetId, dataType);
    
    // Remove outliers using statistical analysis
    const filtered = this.removeOutliers(readings);
    
    // Weighted aggregation based on oracle reputation
    const aggregated = this.weightedAggregate(filtered);
    
    // Validate against Byzantine threshold
    if (this.validateByzantineTolerance(filtered)) {
      return this.finalizeReading(aggregated);
    }
    
    throw new Error('Byzantine fault detected in oracle data');
  }

  weightedAggregate(readings) {
    let totalWeight = 0;
    let weightedSum = 0;

    for (const reading of readings) {
      const weight = this.calculateOracleWeight(reading.oracleId);
      weightedSum += reading.value * weight;
      totalWeight += weight;
    }

    return {
      value: weightedSum / totalWeight,
      confidence: this.calculateConfidence(readings),
      contributors: readings.length
    };
  }

  removeOutliers(readings) {
    const values = readings.map(r => r.value);
    const median = this.calculateMedian(values);
    const mad = this.calculateMAD(values, median); // Median Absolute Deviation
    
    return readings.filter(reading => {
      const deviation = Math.abs(reading.value - median) / mad;
      return deviation <= 2.5; // Remove readings > 2.5 MAD from median
    });
  }
}
```

### Layer 3: Governance Consensus
**Purpose**: Protocol upgrades and parameter changes
**Mechanism**: Quadratic Voting with Time-lock

```javascript
class GovernanceConsensus {
  constructor() {
    this.proposalThreshold = 10000; // RWA tokens to create proposal
    this.votingPeriod = 7 * 24 * 60 * 60 * 1000; // 7 days
    this.timelock = 24 * 60 * 60 * 1000; // 24 hour timelock
    this.quorum = 0.4; // 40% participation required
  }

  async createGovernanceProposal(type, parameters, description) {
    if (this.currentStake < this.proposalThreshold) {
      throw new Error('Insufficient stake for governance proposal');
    }

    const proposal = {
      id: generateProposalId(),
      type, // 'PARAMETER_CHANGE', 'UPGRADE', 'TREASURY'
      parameters,
      description,
      proposer: this.nodeId,
      createdAt: Date.now(),
      votingEnds: Date.now() + this.votingPeriod,
      executionTime: Date.now() + this.votingPeriod + this.timelock
    };

    await this.submitProposal(proposal);
    return proposal.id;
  }

  async quadraticVote(proposalId, preference, credits) {
    // Quadratic voting: cost = votes²
    const cost = Math.pow(preference, 2);
    
    if (credits < cost) {
      throw new Error('Insufficient voting credits');
    }

    const vote = {
      proposalId,
      voter: this.nodeId,
      preference, // -100 to +100
      credits: cost,
      timestamp: Date.now()
    };

    await this.submitQuadraticVote(vote);
    return vote;
  }
}
```

## 🔒 Consensus Security Mechanisms

### 1. Reputation-Based Staking
```javascript
class ReputationStaking {
  calculateEffectiveStake(baseStake, reputation) {
    // Reputation multiplier: 0.5x to 2x
    const reputationMultiplier = Math.max(0.5, Math.min(2.0, reputation / 1000));
    return baseStake * reputationMultiplier;
  }

  async slashForMisbehavior(nodeId, offense) {
    const penalties = {
      FALSE_VALIDATION: 0.1,    // 10% slash
      DOUBLE_VOTING: 0.15,      // 15% slash
      DATA_MANIPULATION: 0.2,   // 20% slash
      LONG_TERM_OFFLINE: 0.05   // 5% slash
    };

    const slashRate = penalties[offense] || 0.1;
    await this.executeSlashing(nodeId, slashRate);
  }
}
```

### 2. Dynamic Difficulty Adjustment
```javascript
class DifficultyAdjustment {
  adjustConsensusThreshold(networkConditions) {
    const baseThreshold = 0.66;
    
    // Increase threshold during high disagreement
    if (networkConditions.disagreementRate > 0.3) {
      return Math.min(0.8, baseThreshold + 0.1);
    }
    
    // Decrease threshold during high agreement
    if (networkConditions.disagreementRate < 0.1) {
      return Math.max(0.6, baseThreshold - 0.05);
    }
    
    return baseThreshold;
  }
}
```

### 3. Anti-Sybil Protection
```javascript
class SybilProtection {
  async validateNewValidator(nodeId, stakeAmount, identityProof) {
    const checks = {
      minimumStake: stakeAmount >= this.minimumStake,
      identityVerification: await this.verifyIdentity(identityProof),
      networkDiversity: await this.checkNetworkDiversity(nodeId),
      cooldownPeriod: await this.checkCooldown(nodeId)
    };
    
    return Object.values(checks).every(check => check);
  }

  async checkNetworkDiversity(nodeId) {
    const geolocation = await this.getNodeGeolocation(nodeId);
    const regionCount = await this.getRegionValidatorCount(geolocation.region);
    const maxRegionRatio = 0.3; // Max 30% validators from same region
    
    return regionCount / this.totalValidators < maxRegionRatio;
  }
}
```

## ⚡ Fast Finality Mechanisms

### 1. Optimistic Consensus
```javascript
class OptimisticConsensus {
  async optimisticFinalize(transaction) {
    // Assume validity, challenge period for disputes
    const finalization = {
      transactionHash: transaction.hash,
      state: 'OPTIMISTIC_FINAL',
      challengePeriod: 1 * 60 * 60 * 1000, // 1 hour
      challengers: [],
      finalizedAt: Date.now()
    };
    
    // Monitor for challenges
    setTimeout(() => {
      if (finalization.challengers.length === 0) {
        this.promoteToFinal(finalization);
      } else {
        this.initiateDispute(finalization);
      }
    }, finalization.challengePeriod);
    
    return finalization;
  }
}
```

### 2. State Channels for High-Frequency Operations
```javascript
class StateChannel {
  async openChannel(participants, initialState) {
    const channel = {
      id: generateChannelId(),
      participants,
      state: initialState,
      nonce: 0,
      timeout: 24 * 60 * 60 * 1000, // 24 hours
      signatures: {}
    };
    
    // All participants must sign opening
    for (const participant of participants) {
      channel.signatures[participant] = await this.signState(channel);
    }
    
    return channel;
  }

  async updateState(channelId, newState) {
    const channel = this.channels.get(channelId);
    
    // Optimistic update
    channel.state = newState;
    channel.nonce++;
    
    // Collect signatures asynchronously
    this.collectSignatures(channel);
    
    return channel;
  }
}
```

## 🌐 Cross-Chain Consensus

### 1. Bridge Validators
```javascript
class BridgeConsensus {
  async validateCrossChainTransfer(sourceChain, targetChain, transfer) {
    const validators = await this.getBridgeValidators();
    const threshold = Math.ceil(validators.length * 0.66);
    
    const validations = await Promise.all(
      validators.map(v => v.validateTransfer(transfer))
    );
    
    const approvals = validations.filter(v => v.approved).length;
    
    if (approvals >= threshold) {
      await this.executeCrossChainTransfer(transfer);
      return { status: 'approved', approvals };
    }
    
    return { status: 'rejected', approvals };
  }
}
```

## 📊 Consensus Metrics and Monitoring

### 1. Real-time Metrics
```javascript
class ConsensusMetrics {
  constructor() {
    this.metrics = {
      finalizationTime: [],
      participationRate: 0,
      slashingEvents: 0,
      forkCount: 0,
      networkHealth: 1.0
    };
  }

  recordFinalization(proposalId, timeToFinalize) {
    this.metrics.finalizationTime.push(timeToFinalize);
    
    // Keep only last 100 measurements
    if (this.metrics.finalizationTime.length > 100) {
      this.metrics.finalizationTime.shift();
    }
  }

  calculateNetworkHealth() {
    const avgFinalizationTime = this.getAverageFinalizationTime();
    const participationPenalty = Math.max(0, 0.8 - this.metrics.participationRate);
    const slashingPenalty = this.metrics.slashingEvents * 0.01;
    
    this.metrics.networkHealth = Math.max(0, 
      1.0 - participationPenalty - slashingPenalty
    );
    
    return this.metrics.networkHealth;
  }
}
```

### 2. Consensus Dashboard
```javascript
// Real-time consensus monitoring
const ConsensusDashboard = {
  activeProposals: 12,
  averageFinalizationTime: "3.2s",
  networkParticipation: "94.2%",
  validatorCount: 25,
  slashingEvents: {
    today: 0,
    thisWeek: 2,
    thisMonth: 5
  },
  reputationDistribution: {
    excellent: 15,  // > 1500 reputation
    good: 8,        // 1000-1500
    average: 2      // < 1000
  },
  consensusHealth: "98.5%"
};
```

## 🚀 Emergency Consensus Procedures

### 1. Emergency Halt Mechanism
```javascript
class EmergencyConsensus {
  async initiateEmergencyHalt(evidence) {
    const superMajority = 0.75; // 75% required for emergency halt
    
    const haltProposal = {
      type: 'EMERGENCY_HALT',
      evidence,
      requiredThreshold: superMajority,
      timeLimit: 30 * 60 * 1000 // 30 minutes to vote
    };
    
    const votes = await this.collectEmergencyVotes(haltProposal);
    
    if (votes.approvalRate >= superMajority) {
      await this.executeEmergencyHalt();
      return true;
    }
    
    return false;
  }
}
```

### 2. Recovery Procedures
```javascript
class ConsensusRecovery {
  async recoverFromPartition() {
    // Longest chain rule with additional validation
    const chains = await this.detectChains();
    const validChain = this.selectValidChain(chains);
    
    // Rollback to common ancestor
    await this.rollbackToCommonAncestor(validChain);
    
    // Replay valid transactions
    await this.replayTransactions(validChain);
    
    return validChain;
  }
}
```

This consensus mechanism ensures the RWA platform maintains decentralization while providing fast finality and robust security for asset verification and trading operations.