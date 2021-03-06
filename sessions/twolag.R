#### Session code for a teo-lag VAR ####

rm(list=ls())

# Define
a <- c(1, 2)
A <- matrix( c( .6, .1, -.2, .5, -.1, .05, .05, .05 ), 2, 4 )
lags <- 2
m.sd <- matrix( c( 1, .2, -.3, .5), 2, 2 )
Sigma <- m.sd %*% t(m.sd)
mu <- mu.calc( a, A )
l.var <- list( a=a, A=A, Sigma=Sigma, mu=mu )

# Simulate
n.sim <- 200
y0 <- matrix( mu, 2, 1 )
sim <- var_sim( a, A, y0, Sigma, n.sim )

# Estimate: OLS
l.var.est <- var.ols( sim, 2 )
irf.plot( l.var, n.pds = 20 )
irf.plot( l.var.est, n.pds = 20 )

# Estimate: MLE
l.var.est.mle <- var.mle.est( sim, 2 )
l.var.rest.mle.u <- var.mle.rest( sim, mu.diff.pos, 2, cond=FALSE, theta=2-diff(l.var.est$mu) )
irf.plot( l.var.rest.mle, n.pds = 20 )
irf.plot( l.var.rest.mle.u, n.pds = 20 )

# Estimate: restricted MLE
l.var.rest.mle <- var.mle.rest( sim, mu.diff.pos, 2, theta=1-diff(l.var.est$mu) )
irf.plot( l.var.rest.mle, n.pds = 20 )

# Infer: OLS + MLE
v.mle <- var.mle.se( sim, l.var.est.mle )
v.mle.est.ineff <- var.mle.se( sim, l.var.est.mle, ineff = TRUE )
v.mle.rest <- var.mle.se( sim, l.var.rest.mle )
v.mle.rest.u <- var.mle.se( sim, l.var.rest.mle.u, cond = FALSE, ineff=TRUE )
print( cbind( v.mle=sqrt(diag(v.mle)), v.mle.est.ineff=sqrt(diag(v.mle.est.ineff)),
              v.mle.rest=sqrt(diag(v.mle.rest)), v.mle.rest.u=sqrt(diag(v.mle.rest.u)) ) )

# Plot vs. simulations
sim.fcast.plot(sim, l.var = l.var.est)
sim.fcast.plot(sim, l.var = l.var.est.mle )
sim.fcast.plot(sim, l.var = l.var.rest.mle )

# Create latex output
l.l.var <- list( l.var.est, l.var.est.mle, l.var.rest.mle )
l.m.var <- list( v.ols$ols.nw, v.mle, v.mle.rest )
v.lhood <- sapply( l.l.var, function(x) var_lhood_N( sim, par.to(x$a, x$A, x$Sigma), 2 ) )
var.table( l.l.var, l.m.var, file='./tests/test_twolag.tex',
           specnames = c('OLS Newey-West', 'MLE', 'Restricted MLE' ),
           caption = 'Two-lag test VAR. In restricted MLE, mean difference is one
           larger than the OLS estimate', label='tab:twolag', footer=TRUE, v.lhood=v.lhood )

# Model tests
v.theta <- seq( .01, .8, length.out=10)
lr.wald.plot( sim, lags, mu.diff.pos, v.theta, offset=diff(l.var.est$mu) )
