# Selfish miner ignores detective blocks

Mining simulation where the selfish miner ignores completely the presence of detective blocks.
Detectives, once they have successfully mined a detective block, switch back to mining on the honest chain.
The selfish miner only publishes their chain (and the detective chain tip if present), when the honest chain reduces the
selfish lead to one block.

Results are again for either detectives building on the tip of the selfish chain or 2nd from the top.

Code is a bit iffy but assuming correct it shows detective mining makes things worse if the selfish miner ignores detectives,
and it seems that ignoring detectives can be more profitable than immediately publishing as soon as one detective block is seen.

Another possibility is for detectives to build on top of existing detective blocks, essentially selfish mining on top of the selfish chain, but
not hidden from the selfish miner. This is not investigated here.  However this is probably not a good idea.  Detective blocks probably need to be empty
to avoid the case of the selfish miner having a tx included in a selfish block and then broadcasting it later
to be included by detectives, rendering them invalid.  Large reorgs with empty blocks would be a horrible outcome.
