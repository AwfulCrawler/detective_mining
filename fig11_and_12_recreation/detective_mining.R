#Attempt to implement the detective mining model/s and recreate figures.
#
#To produce all plots and save as files:
#In R console
#   > source("./detective_mining.R")
#   > recreate_all_paper_plots()


#Create all plots, building on the tip of selfish miners or building on the 2nd to top.
recreate_all_paper_plots <- function(){
    set.seed(1337)
    print("Creating detective plots building on the tip...")
    print("=========================================================")
    print("Figure 11")
    print("---------")
    recreate_paper_fig11(fname_prefix="f11_buildontip_gamma")

    print("Figure 12")
    print("---------")
    recreate_paper_fig12(fname_prefix="f12_buildontip_alpha")
    print("---------------------------------------------------------")
    writeLines("\n\n\n")

    print("Creating detective plots building on 2nd top...")
    print("=========================================================")
    print("Figure 11")
    print("---------")
    recreate_paper_fig11(build_on_tip=FALSE, fname_prefix="f11_build2ndtop_gamma")

    print("Figure 12")
    print("---------")
    recreate_paper_fig12(build_on_tip=FALSE, fname_prefix="f12_build2ndtop_alpha")
}

#----------------------------------------------------------------------------------------------
#Figure 11 procedures
recreate_paper_fig11 <- function(build_on_tip=TRUE, fname_prefix="gamma"){
    print("Creating plots for gamma = 0")
    print("----------------------------")
    fname <- paste("./",fname_prefix,"_000.png",sep="")
    png(filename=fname, width=960, heigh=960)
    recreate_paper_fig11_subplot(0, build_on_tip)
    dev.off()
    print("----------------------------")

    print("Creating plots for gamma = 0.5")
    print("----------------------------")
    fname <- paste("./",fname_prefix,"_050.png",sep="")
    png(filename=fname, width=960, heigh=960)
    recreate_paper_fig11_subplot(0.5, build_on_tip)
    dev.off()
    print("----------------------------")

    print("Creating plots for gamma = 1")
    print("----------------------------")
    fname <- paste("./",fname_prefix,"_100.png",sep="")
    png(filename=fname, width=960, heigh=960)
    recreate_paper_fig11_subplot(1, build_on_tip)
    dev.off()
    print("----------------------------")
}

recreate_paper_fig11_subplot <- function(g, build_on_tip){
    alpha_values <- seq(0,0.49 ,by=0.01)
    print("Calculating for theta=0 ...")
    theta000_data <- generate_fig11_results(alpha_values, g, 0, build_on_tip)
    print("Calculating for theta=0.5 ...")
    theta050_data <- generate_fig11_results(alpha_values, g, 0.5, build_on_tip)
    print("Calculating for theta=1 ...")
    theta100_data <- generate_fig11_results(alpha_values, g, 1, build_on_tip)

    plot_title <- sprintf("gamma = %0.2f", g)
    plot(alpha_values , theta000_data$selfish_ratio, type="l", col="blue"     , lwd=2, lty=2
         , main=plot_title, xlab="proportion of selfish hashrate", ylab="proportion of blocks mined")
    lines(alpha_values, theta050_data$selfish_ratio, type="l", col="red"      , lwd=2, lty=4)
    lines(alpha_values, theta100_data$selfish_ratio, type="l", col="darkgreen", lwd=2, lty=3)
    lines(alpha_values, alpha_values , type="l", col="black"    , lwd=2, lty=1)
    legend("topleft", c("theta=0%","theta=50%","theta=100%","Honest mining"), lty=c(2,4,3,1), 
           col=c("blue","red","darkgreen","black"), lwd=2)

    #Return the selfish mining RER for all the three values of theta
    #in order to be able to check the consistency of the results with generated figure 12's.
    #Check that the selfish miner's relative extra revenue is in the ballpark of the 
    #values returned for values 0, 50, 100
    RER <- c()
    for (a in c(35,40,45)){
        n     <- toString(a)
        index <- a+1
        alpha <- a/100
        
        selfish_ratios <- c(theta000_data$selfish_ratio[index],
                            theta050_data$selfish_ratio[index],
                            theta100_data$selfish_ratio[index])

        RER[[n]] <- (selfish_ratios - alpha)/alpha
    }
    return(RER)
}


generate_fig11_results <- function(alpha_values, g, t, build_on_tip){
    results <- c()
    for (a in alpha_values){
        result  <- simulate_paper_mining(a, g, t, build_on_tip)
        for (n in names(result)){
            results[[n]] <- c(results[[n]],result[[n]])
        }
        #results <- c(results, result$selfish_ratio)
    }
    return(results)
}
#----------------------------------------------------------------------------------------------

#----------------------------------------------------------------------------------------------
#Fig 12 code
recreate_paper_fig12 <- function(build_on_tip=TRUE, fname_prefix="alpha"){
    print("Creating plot for alpha=0.35")
    fname <- paste("./", fname_prefix, "_035.png",sep="")
    png(filename=fname, width=960, heigh=960)
    recreate_paper_fig12_subplot(0.35, build_on_tip)
    dev.off()
    
    print("Creating plot for alpha=0.40")
    fname <- paste("./", fname_prefix, "_040.png",sep="")
    png(filename=fname, width=960, heigh=960)
    recreate_paper_fig12_subplot(0.40, build_on_tip)
    dev.off()

    print("Creating plot for alpha=0.45")
    fname <- paste("./", fname_prefix, "_045.png",sep="")
    png(filename=fname, width=960, heigh=960)
    recreate_paper_fig12_subplot(0.45, build_on_tip)
    dev.off()
}

recreate_paper_fig12_subplot <- function(a, build_on_tip){
    theta_values <- seq(0,1,by=0.01)
    results <- generate_fig12_results(a, 0.5, theta_values, build_on_tip)

    #Relative Revenues
    delta_values <- theta_values*(1-a)

    RER_selfish   <- (results$selfish_ratio - a)/a
    RER_honest    <- (results$honest_ratio - (1-a-delta_values))/(1-a-delta_values)
    RER_detective <- (results$detective_ratio - delta_values)/delta_values
   
    plot_title <- sprintf("alpha = %0.2f", a)
    plot(theta_values , RER_selfish   , type="l", col="blue"     , lwd=2, lty=1,
         main=plot_title, xlab="theta", ylab="RER", xlim=c(0,1), ylim=c(-0.5,0.5),
         xaxp=c(0,1,10), yaxp=c(-0.5,0.5,10))
 
    lines(theta_values, RER_detective , type="l", col="darkgreen", lwd=2, lty=4)
    lines(theta_values, RER_honest    , type="l", col="red"      , lwd=2, lty=2)
    lines(theta_values, theta_values*0, type="l", col="black"    , lwd=1, lty=1)
    grid(nx=NULL, ny=NULL, lty=2, col="gray", lwd=1)

    legend("topright", c("Selfish","Detective","Other honest miners"), lty=c(1,4,2), 
           col=c("blue","darkgreen","red"), lwd=2)
}

generate_fig12_results <- function(a, g, theta_values, build_on_tip){
    results <- c()
    for (t in theta_values){
        result <- simulate_paper_mining(a, g, t, build_on_tip)
        for (n in names(result)){
            results[[n]] <- c(results[[n]], result[[n]])
        }
    }
    return(results)
}
#----------------------------------------------------------------------------------------------

#Mining simulation following the rules of the paper
#
#build_on_tip == TRUE means the model is as described in the paper and the detective miners
#build on the top of the selfish chain.  Detective miners act like honest miners in the case of a fork
#and have a probability of gamma of following the selfish fork candidate.
#
#build_on_tip == FALSE means the detective miners mine on the 2nd to top block of the selfish hidden chain
#(which means mining on the honest chain when the selfish chain only includes one hidden block),
#and the detectives never mine on a selfish fork candidate.
#
#Returns:
#   - A named list with the win ratios for selfish miners, detective miners and honest miners (non-detectives)
#   - names: "selfish_ratio", "detective_ratio", "honest_ratio"
simulate_paper_mining <- function(alpha, gamma, theta, build_on_tip, N=50000){
    #set.seed(1337)
    selfish_lead   <- 0 #variable c in paper
    selfish_length <- 0 #the length of the alternative head

    #Results which we are keeping track of
    #-------------------------------------
    selfish_wins   <- 0 #number of blocks won by the selfish miner
    detective_wins <- 0 #number of blocks won by detectives (even when they are honest mining)
    honest_wins    <- 0 #number of blocks won by honest mining hashrate which is never detective rate
    #-------------------------------------

    chain_length   <- 0 #the length of the chain up to where the selfish miner has split off.
    delta <- theta*(1-alpha)

    #Pregenerate uniform random values between 0 and 1.
    #We need at most 2*N for the loop below
    #This is faster than generating one at a time when needed
    rand_vals  <- runif(2*N)
    rand_index <- 0

    while (chain_length < N){
        rand_index <- rand_index + 1
        x <- rand_vals[rand_index]
        #x <- runif(1)
        #x < alpha means selfish mined block
        #alpha <= x < 1- delta means a normal miner mined a block (in the case when detective mining is active)
        #x >= 1-delta means a detective block is broadcast.  OR that an honest miner mined a block in the case
        #that there is no selfish alternative chain growing.

        if (x < alpha){
            #The selfish miner has found a block. Its lead and the length of the private chain
            #increase by one regardless of anything else.
            selfish_lead   <- selfish_lead + 1
            selfish_length <- selfish_length + 1
        }
        else if (selfish_lead == 0){ #& x >= alpha){
            #An honest miner has found a block [probability (1-alpha)] because there is no selfish alt chain
            #Chain length just increases by one
            chain_length <- chain_length + 1

            #Credit the honest win to the appropriate miners
            if (x < (1-delta)){
                honest_wins <- honest_wins + 1
            }
            else{
                detective_wins <- detective_wins + 1
            }
        }
        else if (selfish_lead > 0 & x >= (1-delta)){
            #The selfish miner has a lead but a detective block was mined on top of it (probability delta).
            #Therefore it reveals its blocks, gets the rewards and the undisputed blockchain extends by the length
            #of the selfish chain plus one for the detective.

            #If building on the top it is uncomplicated.
            if (build_on_tip){
                selfish_wins   <- selfish_wins + selfish_length
                detective_wins <- detective_wins + 1
            }
            else{
                #If building on the 2nd to top we resolve a fork situation
                #Either:
                # - selfish miner mines on selfish chain
                # - honest miner mines on selfish chain
                # - honest miner mines on chain with detective tip
                # - detective miner mines on chain with detective tip
                #Different win distribution for each outcome
                rand_index <- rand_index+1
                y <- rand_vals[rand_index]
                if (y < alpha){
                    #selfish mined on selfish fork.  Wins 1 extra
                    selfish_wins <- selfish_wins + selfish_length + 1
                }
                else if (y < alpha + gamma*(1-alpha-delta)){
                    #Honest mined on selfish fork
                    selfish_wins <- selfish_wins + selfish_length
                    honest_wins  <- honest_wins + 1
                }
                else{
                    #honest or detective miner mined on the chain with detective block at the tip
                    selfish_wins <- selfish_wins + selfish_length - 1

                    #detectives either win one or two depending on who confirmed the last block
                    if (y < 1-delta){
                        #honest mined on detective fork of selfish chain
                        honest_wins    <- honest_wins + 1
                        detective_wins <- detective_wins + 1
                    }
                    else{
                        #detective mined on detective fork of sefish chain
                        detective_wins <- detective_wins + 2
                    }
                }
            }
            chain_length <- chain_length + selfish_length + 1 #add one for detective block/fork confirming block
            selfish_length <- 0
            selfish_lead   <- 0
        }
        else if (selfish_lead == 1 & x < (1-delta)){ # & x >= alpha){  
            #The selfish miner had a lead of only one block (and therefore a total selfish chain of only one).
            #A regular honest block has been found (probability 1-alpha-delta).
            #The selfish miner publishes his block and the fork is resolved.
            #In the case where the detectives don't build on the tip they never mine on the selfish fork candidate,
            #which complicates the if statement a bit.  It might probably preferable for readability to
            #do this in separate functions rather than have a build_on_tip boolean parameter, even if code is
            #duplicated.

            rand_index <- rand_index+1
            y <- rand_vals[rand_index]
            selfish_lead   <- 0
            selfish_length <- 0
            if (y < alpha){
                #selfish miner confirms his own block honestly, resolving the fork and winning 2 blocks
                selfish_wins <- selfish_wins + 2
            }
            else if (y < alpha + gamma*(1-alpha-delta)){
                #selfish miner's block is built on by honest miners
                selfish_wins <- selfish_wins + 1
                honest_wins  <- honest_wins  + 1
            }
            else if (y < alpha + gamma*(1-alpha) & build_on_tip){
                #detective miners never mine on selfish fork candidates if not build_on_tip
                selfish_wins   <- selfish_wins + 1
                detective_wins <- detective_wins + 1
            }
            else if (y < 1-delta & !build_on_tip){
                #honest miners built on honest block
                honest_wins <- honest_wins + 2
            }
            else if (y < alpha + gamma*(1-alpha) + (1-gamma)*(1-alpha-delta) & build_on_tip){  #= 1-(1-gamma)*delta
                honest_wins <- honest_wins + 2
            }
            else{
                #detective miner builds on honest block
                honest_wins    <- honest_wins + 1
                detective_wins <- detective_wins +1
            }
            chain_length <- chain_length + 2 #two blocks are added, the fork height blocks and the next block resolving the fork
        }
        else if (selfish_lead > 1 & x < 1-(delta)){  #& x >= alpha){
            #The selfish miner has at least a 2 block lead but an honest miner has extended the honest chain.
            #Selfish miner loses one block of lead on the honest chain.
            #If lead is now one, the selfish miner publishes the chain, gets the rewards and the undisputed chain
            #length inreases by the length of the selfitheta=sh miner's private chain
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

    return(list("selfish_ratio"   = selfish_wins/chain_length,
                "honest_ratio"    = honest_wins/chain_length,
                "detective_ratio" = detective_wins/chain_length))
}
