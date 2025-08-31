recreate_paper_plots <- function(){
    print("Creating plots for gamma = 0")
    print("----------------------------")
    png(filename="~/gamma_000.png", width=960, heigh=960)
    recreate_paper_plot(0)
    dev.off()
    print("----------------------------")

    print("Creating plots for gamma = 0.5")
    print("----------------------------")
    png(filename="~/gamma_050.png", width=960, heigh=960)
    recreate_paper_plot(0.5)
    dev.off()
    print("----------------------------")

    print("Creating plots for gamma = 1")
    print("----------------------------")
    png(filename="~/gamma_100.png", width=960, heigh=960)
    recreate_paper_plot(1)
    dev.off()
    print("----------------------------")
}

recreate_paper_plot <- function(g){
    alpha_values <- seq(0,0.49,by=0.01)
    print("Calculating for theta=0 ,,,")
    theta000_data <- generate_plot_yvalues(alpha_values, g, 0)
    print("Calculating for theta=0.5 ...")
    theta050_data <- generate_plot_yvalues(alpha_values, g, 0.5)
    print("Calculating for theta=1 ...")
    theta100_data <- generate_plot_yvalues(alpha_values, g, 1)

    plot_title <- sprintf("gamma = %0.2f", g)
    plot(alpha_values, theta000_data, type="l", col="blue", lwd=2, lty=2
         , main=plot_title, xlab="proportion of selfish hashrate", ylab="proportion of blocks mined")
    lines(alpha_values, theta050_data, type="l", col="red", lwd=2, lty=4)
    lines(alpha_values, theta100_data, type="l", col="darkgreen", lwd=2, lty=3)
    lines(alpha_values, alpha_values, type="l", col="black", lwd=2, lty=1)
    legend("topleft", c("theta=0%","theta=50%","theta=100%","Honest mining"), lty=c(2,4,3,1), col=c("blue","red","darkgreen","black"), lwd=2)
}

generate_plot_yvalues <- function(alpha_values, g, t){
    results <- c()
    for (a in alpha_values){
        result  <- simulate_mining(alpha=a, gamma=g, theta=t)
        results <- c(results, result)
    }
    return(results)
}

simulate_mining <- function(N=50000, alpha, gamma, theta){
    #set.seed(1337)
    selfish_lead   <- 0 #variable c in paper
    selfish_length <- 0 #the length of the alternative head
    selfish_wins   <- 0 #number of blocks won by the selfish miner
    chain_length   <- 0 #the length of the chain up to where the selfish miner has split off.
    delta <- theta*(1-alpha)
    while (chain_length < N){
        x <- runif(1)
        #x < alpha means selfish mined block
        #alpha <= x < 1- delta means a normal miner mined a block (in the case when detective mining is active)
        #x >= 1-delta means a detective block is broadcast.  OR that an honest miner mined a block in the case
        #that there is no selfish alternative chain growing.

        #z <- runif(1)
        if (x < alpha){
            #The selfish miner has found a block. It's lead and the length of the private chain
            #increase by one regardless of anything else.'
            selfish_lead   <- selfish_lead + 1
            selfish_length <- selfish_length + 1
        }
        else if (selfish_lead == 0){ #& x >= alpha){
            #An honest miner has found a block [probability (1-alpha)] because there is no selfish alt chain
            #Chain length just increases by one
            chain_length <- chain_length + 1
        }
        else if (selfish_lead > 0 & x >= (1-delta)){
            #The selfish miner has a lead but a detective block was mined on top of it (probability delta).
            #Therefore it reveals its blocks, gets the rewards and the undisputed blockchain extends by the length
            #of the selfish chain plus one for the detective.

            #INCORRECT VERSION WHICH YIELDS GRAPHS LIKE IN THE PAPER:
            #We go into a fork situation for some reason between the last block of the selfish miner and the detective block.
            #the honest miners who follow the fork are (1-alpha-delta)*gamma.
            #This is wrong because it would require the detective block to be produced on the 2nd to last block of the selfish chain.
            #This does not match the description in the paper but it's the only thing I could come up with to match the graphs.
            #It's also a completely different and even more unbeleivable model than what they describe in words in the paper.
            y <- runif(1)
            if (y < alpha){
                selfish_wins <- selfish_wins + selfish_length + 1
            }
            else if (y < alpha + gamma*(1-alpha-delta)){
                selfish_wins <- selfish_wins + selfish_length
            }
            else{
                selfish_wins <- selfish_wins + selfish_length - 1
            }

            chain_length <- chain_length + selfish_length + 1 #add one for detective block

            selfish_length <- 0
            selfish_lead   <- 0
        }
        else if (selfish_lead == 1 & x < (1-delta)){ # & x >= alpha){  #honest miner mined we are in a fork
            #The selfish miner had a lead of only one block (and therefore a total selfish chain of only one).
            #A regular honest block has been found (probability 1-alpha-delta).
            #The selfish miner publishes his block.  There is a probability of gamma that the honest miners
            #mine on top of the selfish published block.  The selfish miner also tries to mine on his own block
            #possible outcomes: 1) selfish miner gets the next block and therefore 2 block rewards
            #2) honest miners find a block on top of the selfish block and selfish miner gets 1 reward
            #3) honest miners find a block on top of the honest block and selfish miner gets nothing
            y <- runif(1)
            selfish_lead   <- 0
            selfish_length <- 0
            if (y < alpha){
                #selfish miner confirms his own block honestly, resolving the fork and winning 2 blocks
                selfish_wins <- selfish_wins + 2
            }
            else if (y < alpha + gamma*(1-alpha-delta)){
                #selfish miner's block is built on by honest miners
                #Again this is a modification from the paper where actually the detective miners have zero chance of
                #following the selfish miners fork.  This doesn't make much of a difference so I'm not as certain about it
                #being something additional they did to deviate from their own description in the paper.
                selfish_wins <- selfish_wins + 1
            }
            chain_length <- chain_length + 2 #two blocks are added, the fork height blocks and the next block resolving the fork
        }
        else if (selfish_lead > 1 & x < 1-(delta)){  #& x >= alpha){
            #The selfish miner has at least a 2 block lead but an honest miner has extended the honest chain.
            #Selfish miner loses one block of lead on the honest chain.
            #If lead is now one, the selfish miner publishes the chain, gets the rewards and the undisputed chain
            #length inreases by the length of the selfish miner's private chain'
            selfish_lead <- selfish_lead - 1
            if (selfish_lead == 1){
                #main chain is catching up, publish selfish chain
                selfish_wins   <- selfish_wins + selfish_length
                chain_length   <- chain_length + selfish_length
                selfish_length <- 0
                selfish_lead   <- 0
            }
        }


        #Check whether chain_length + selfish_length is >= N if so selfish miner wins those last blocks
        if (chain_length + selfish_length >= N){
            selfish_wins   <- selfish_wins + selfish_length
            chain_length   <- chain_length + selfish_length
            selfish_length <- 0
            selfish_lead   <- 0
        }
    }

    return(selfish_wins/chain_length)
}
