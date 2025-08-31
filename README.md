# Detective Mining Simulation

Simulations relating to the [detective mining](https://eprint.iacr.org/2019/486) paper.
The first_attempt directory has a first basic attempt at producing fig 11. fig11_and_12_recreation has a bigger script attempting to recreate all plots in
fig 11 and fig 12.  I cannot reproduce fig 12 at the moment.  See notes below.

## Table of Contents

  - [The paper implements their own model incorrectly](#the-paper-implements-their-own-model-incorrectly)
  - [Issues with the assumptions of the paper](#issues-with-the-assumptions-of-the-paper)
  - [Figure 12 appears to be incorrect](#figure-12-appears-to-be-incorrect)
  - [Things to do](#things-to-do)

## The paper implements their own model incorrectly

In the paper, the detective miners mine on the tip of the current selfish chain.  To see that the results in fig. 11 of the
paper are incorrect, consider the case where theta=100%.  In all three subplots in the paper, this line is below honest mining
profitability for the whole hash-rate range of the selfish miner.

However, if theta=100%, when a selfish miner wins a block, all hashrate switches to the selfish tip.  Eventually when a
detective block is mined, none of the selfish blocks are orphaned.  In fact no honest block is ever orphaned either.  The
selfish miner (hashrate alpha) is always competing against all of the honest hashrate (1-alpha), without any orphans from either
side.  This is the same as honest mining, so the case theta=100% corresponds to honest mining profitability.

In order to match the graphs in the paper, with all else being equal, the detective miners must mine on the 2nd to top selfish
block instead.  In the case of a selfish lead of one block, the detectives stay on the honest chain.  See the rudimentary scripts
already implemented in the first_attempt directory, as well as the resulting graphs.

## Figure 12 appears to be incorrect

I have been trying to recreate figure 12 and have been unsuccessful both with having detective miners build on the tip of the selfish chain
and having them build on the 2nd to top.  Looking closer at figure 12 I believe it does not match figure 11 in the places where it should,
and is therefore incorrect.

In the paper, the x axis of figure 12 is labelled "Leakage ratio (%)", a term which is used nowhere else in the paper.
However on the previous page of the paper they state:
>The X-axis of the graph means variation of the ratio of the detective mining to the miners except the selfish miners

The "ratio of detective mining to the miners except selfish miners" matches their description of theta, so one can reasonably deduce that the x axis
is theta.  This also makes sense since in each subplot of figure 12 gamma is 0.5 and alpha is held constant.  Thus theta is the only thing left to vary.

With that confusion out of the way, when theta is 100% the relative extra revenue (RER) should match what we see in figure 11.  In figure 11, for theta = 100%
it can be seen that for the hashrates alpha=0.35, 0.40, 0.45, selfish mining is LESS PROFITABLE THAN HONEST MINING, and therefore the RER should be NEGATIVE at
theta = 100% for ALL SUBPLOTS in figure 12.  However, if you look at the subplots for alpha = 0.4 and alpha = 0.5, you can see that the RER for selfish mining
is all positive.  Therefore the graphs don't match.

The directory fig11_and_12_recreation contains code and plots for fig11 and fig12 which are consistent with each other, although I am not 100% sure
of the results.

## Issues with the assumptions of the paper

In the paper, they assume that the selfish miner reveals their hidden blocks as soon as they see a detective block.  The assumption
is inaduately justified.

  - If profit is defined as percent of blocks mined, then it *may* be the profit-maximising strategy, but this deserves investigation
  - Even if it *is* the profit maximising strategy as defined by the percent of blocks mined; in the real world, profit can be
  made by other means than mining (i.e. a botnet operator may be being paid to attack the network,  etc.)
  - Even if it *still is* the profit-maximising strategy after the above considerations, the attacker might be motivated by
  other reasons, such as disrupting or freezing the blockchain.
  - Even if the attacker isn't interested in disrupting or freezing the blockchain *and* it is the profit-maximising strategy,
  the attacker may not be rational

All of the above points make this a risky assumption.  When considering implementing detective mining the risk of increasing reorg
length should be taken into serious consideration.

It occurs to me that even with a naive definition of profit it should rather be number of blocks per unit time, rather than percentage of blocks won.
Assuming a constant block time this won't make a difference, but the presence of the selfish mining must have some effect on the difficulty adjustment (and therefore time between blocks).  I think one could expect it to be a negligible difference but this is not an established fact and should probably be investigated.
This is probably outside the scope of what I am trying to do here.  

I want to emphasize that I believe it is premature to state as fact that this proposal is *the* answer to selfish mining.  The risks of being wrong are too great
and warrant a corresponding degree of scepticism and scrutiny.

## Things to do

With the toy model from the paper as a starting point, I intend to try different selfish mining strategies under the correct (mine the tip) and incorrect (mine 2nd from the tip) detective mining implementations, as well as variations in the honest mining response.

In no particular order:

  - Recreate fig. 12 of the paper.
  - Record more statistics during simulation (e.g. longest reorg, things like that)
  - More plots related to other statistics, other parameter ranges
  - Investigate selfish miner ignores detective blocks strategy
  - Investigate selfish miner incorporates detective blocks strategy
