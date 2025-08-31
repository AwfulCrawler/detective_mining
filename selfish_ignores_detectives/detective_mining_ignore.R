#Attempt to implement the detective mining model/s and recreate figures.
#
#To produce all plots and save as files:
#In R console
#   > source("./detective_mining_ignore.R")
#   > recreate_all_paper_plots()


#Create all plots, building on the tip of selfish miners or building on the 2nd to top.
recreate_all_paper_plots <- function(){
    set.seed(42069)
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
        result  <- simulate_ignore_mining(a, g, t, build_on_tip)
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
    #There are some NANs in there because we include 0 and 100 as values of theta
    L <- length(RER_selfish)
    yvals <- c(RER_selfish[-c(1,L)], RER_honest[-c(1,L)], RER_detective[-c(1,L)])

    ymax <- max(yvals)
    ymin <- min(yvals)

    ymax   <- ceiling(11*ymax+1)
    ymin   <- floor(11*ymin+1)
    yticks <- ymax-ymin + 1
    ymax   <- ymax/10
    ymin   <- ymin/10

    plot_title <- sprintf("alpha = %0.2f", a)
    plot(theta_values , RER_selfish   , type="l", col="blue"     , lwd=2, lty=1,
         main=plot_title, xlab="theta", ylab="RER", xlim=c(0,1), ylim=c(ymin,ymax),
         xaxp=c(0,1,10))#, yaxp=c(ymin,ymax,yticks))
 
    lines(theta_values, RER_detective , type="l", col="darkgreen", lwd=2, lty=4)
    lines(theta_values, RER_honest    , type="l", col="red"      , lwd=2, lty=2)
    lines(theta_values, theta_values*0, type="l", col="black"    , lwd=1, lty=1)
    #grid(nx=NULL, ny=NULL, lty=2, col="gray", lwd=1)

    legend("topright", c("Selfish","Detective","Other honest miners"), lty=c(1,4,2), 
           col=c("blue","darkgreen","red"), lwd=2)
}

generate_fig12_results <- function(a, g, theta_values, build_on_tip){
    results <- c()
    for (t in theta_values){
        result <- simulate_ignore_mining(a, g, t, build_on_tip)
        for (n in names(result)){
            results[[n]] <- c(results[[n]], result[[n]])
        }
    }
    return(results)
}
#----------------------------------------------------------------------------------------------

#Mining simulation where the selfish miner ignores completely the presence of detective blocks.
#Detectives, once they have successfully mined a detective block, switch back to mining on the honest chain.
#Another possibility is for detectives to build on top of existing detective blocks.  This is not
#investigated here.  However this is probably not a good idea.  Detective blocks probably need to be empty
#to avoid the case of the selfish miner having a tx included in a selfish block and then broadcasting it later
#to be included by detectives.  Large reorgs with empty blocks are a horrible outcome.
#
#build_on_tip == TRUE means the detective miners build on the top of the selfish chain.  
#Detective miners act like honest miners in the case of a fork
#and have a probability of gamma of following the selfish fork candidate.
#
#build_on_tip == FALSE means the detective miners mine on the 2nd to top block of the selfish hidden chain
#(which means mining on the honest chain when the selfish chain only includes one hidden block),
#and the detectives never mine on a selfish fork candidate.
#
#There is no difficulty adjustment/cumulative difficulty of alternative chains
#The longest chain wins.  
#
#Returns:
#   - A named list with the win ratios for selfish miners, detective miners and honest miners (non-detectives)
#   - names: "selfish_ratio", "detective_ratio", "honest_ratio"
simulate_ignore_mining <- function(alpha, gamma, theta, build_on_tip, N=50000){
    #set.seed(1337)
    selfish_lead   <- 0 #variable c in paper
    selfish_length <- 0 #the length of the alternative head
    detective_alt  <- FALSE  #Is there a detective built on the 2nd to top of the selfish chain at the moment?
    detective_tip  <- FALSE  #Is there a detective built on top of the selfish chain tip at the moment?

    #Results which we are keeping track of
    #-------------------------------------
    selfish_wins   <- 0 #number of blocks won by the selfish miner
    detective_wins <- 0 #number of blocks won by detectives (even when they are honest mining)
    honest_wins    <- 0 #number of blocks won by honest mining hashrate which is never detective rate
    #-------------------------------------

    chain_length   <- 0 #the length of the chain up to where the selfish miner has split off.
    delta <- theta*(1-alpha)

    #Pregenerate uniform random values between 0 and 1.
    #Need more random numbers than before because detective blocks being found cause a loop without
    #necessarily adding to chain_length in the end.
    #This is faster than generating one at a time when needed
    rand_vals  <- runif(4*N)
    rand_index <- 0

    while (chain_length < N){
        rand_index <- rand_index + 1
        x <- rand_vals[rand_index]
        
        #detectives_active determines whether to allocate detective mining to selfish chain or honest
        #depending on whether a detective block is already generated at the tip/2nd to tip.
        #This is irrelevant if there is no selfish alt chain present
        detectives_active <- (build_on_tip & !detective_tip) | (!build_on_tip & !detective_alt)

        if (x < alpha){
            #The selfish miner has found a block. Its lead and the length of the private chain
            #increase by one regardless of anything else.
            selfish_lead   <- selfish_lead + 1
            selfish_length <- selfish_length + 1
            if (detective_tip){
                detective_tip <- FALSE
                detective_alt <- TRUE
            }
            else{
                detective_alt <- FALSE
            }
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
        else if (selfish_lead > 0 & x >= (1-delta) & detectives_active){
            #The selfish miner has a lead and a detective block has been mined either on top or 2nd from the top
           
            #If we aren't building on tip this induces a fork when selfish_lead == 1 so we need to
            #resolve the fork 
            if (selfish_lead == 1 && !build_on_tip){
                #For situation to resolve
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
                #Didn't add chain length here was causing random values to run out
                chain_length   <- chain_length + selfish_length + 1 #Note selfish_length should be 1 anyway
                selfish_lead   <- 0
                selfish_length <- 0
                detective_alt  <- FALSE
                detective_tip  <- FALSE
            }
            else if (build_on_tip){
                #no fork situation so just note that a detective block is present
                detective_tip <- TRUE
            }
            else{
                detective_alt <- TRUE
            }
        }
        else if (selfish_lead == 1 & (x < (1-delta) | !detectives_active )){ # & x >= alpha){  
            #The selfish miner had a lead of only one block (and therefore a total selfish chain of only one).
            #A regular honest block has been found (probability 1-alpha-delta).
            #The selfish miner publishes his block and the fork is resolved.
            #In the case where the detectives don't build on the tip they never mine on the selfish fork candidate.

            #In this condition, we should never have an honest block candidate, detective candidate and selfish candidate
            #at the same time.  We might have an honest candidate at the same height as the selfish block, but the
            #selfish block already has a detective built on top of it.  In this case the selfish block plus the detective
            #are accepted. 
            #
            #The only time !detectives_active in this condition is if detective_tip, so if a detective miner
            #aiding the honest chain gets the block to equal the selfish chain height, it gets annihilated because
            #there is a detective tip extending the selfish chain.  No need to resolve a fork then since it's pretty much
            #like the selfish chain had a 2 block lead.
            
            selfish_lead   <- 0
            selfish_length <- 0
            detective_tip  <- FALSE
            detective_alt  <- FALSE
            if (detective_tip){
                #This is correct
                selfish_wins   <- selfish_wins + 1
                detective_wins <- detective_wins + 1
            }
            else{
                #Note still checking build_on_tip because !build_on_tip means the detectives never
                #ever mine on a selfish fork candidate.
                
                #Might need a subroutine for this one to resolve forks
                #Otherwise this is going to be copypasted 3 times.
                #But maybe just yolo
                rand_index <- rand_index+1
                y <- rand_vals[rand_index]
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
            }
            chain_length <- chain_length + 2 #two blocks are added, the fork height blocks and the next block resolving the fork
        }
        else if (selfish_lead > 1 & (x < 1-(delta) | !detectives_active)){  #& x >= alpha){
            #The selfish miner has at least a 2 block lead but an honest miner (or detective which has switched
            #over to help the honest chain after already finding a detective block) has extended the honest chain.
            #Selfish miner loses one block of lead on the honest chain.
            #If lead is now one, the selfish miner publishes the chain, gets the rewards and the undisputed chain
            #length inreases by the length of the selfish miner's private chain.
            #If there is a detective_alt present, then that fork needs to be resolved
            selfish_lead <- selfish_lead - 1
            if (selfish_lead == 1){
                #main chain is catching up, publish selfish chain
                #We might be in a fork situation with a detective block at the same height
                #Or we might have a detective block on top of the selfish chain
                if (detective_tip){
                    detective_wins <- detective_wins + 1
                    selfish_wins   <- selfish_wins + selfish_length
                    chain_length   <- chain_length + selfish_length + 1
                }
                else if (detective_alt){
                    #Currently this has both versions of detective mining ignoring the selfish fork
                    #candidate.  Not consistent with the original paper's description of detective
                    #mining on the tip, but makes sense for detective miners to favour their own blocks.
                    #TODO: Maybe change this.  Chaning it will increase selfish mining profitability in
                    #the case of build_on_tip.
                    #resolve the fork between the detective alt and the selfish tip
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
                    chain_length <- chain_length + selfish_length + 1
                }
                else{
                    selfish_wins   <- selfish_wins + selfish_length
                    chain_length   <- chain_length + selfish_length
                }
                selfish_length <- 0
                selfish_lead   <- 0
                detective_tip  <- FALSE
                detective_alt  <- FALSE
            }
        }


        #Check whether chain_length + selfish_length is >= N if so selfish miner wins those last blocks
        if (chain_length + selfish_length >= N){
            #We might have a detective alt or tip to take care of.
            #Another copy-paste resolve fork situation
            if (detective_tip){
                detective_wins <- detective_wins + 1
                selfish_wins   <- selfish_wins + selfish_length
                chain_length   <- chain_length + selfish_length + 1
            }
            else if (detective_alt){
                #resolve the fork between the detective alt and the selfish tip
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
                chain_length <- chain_length + selfish_length + 1
            }
            else{
                selfish_wins   <- selfish_wins + selfish_length
                chain_length   <- chain_length + selfish_length
            }
            selfish_length <- 0
            selfish_lead   <- 0
            detective_tip  <- FALSE
            detective_alt  <- FALSE
        }
    }

    return(list("selfish_ratio"   = selfish_wins/chain_length,
                "honest_ratio"    = honest_wins/chain_length,
                "detective_ratio" = detective_wins/chain_length))
}
