data {
  int<lower=0> N;
  int<lower=0> N_years;
  int<lower=0> SS;
  int<lower=0> V;
  vector[N]    CPUE;
  int          Detect[N];
  int          year[N];
  int          station[N];
  vector[N]    depth;
  int          vessel[N];
}
parameters {
  // Detection model -----------------------------------------------------------
  vector[N_years] Y_det;
  vector[SS]      S_det;
  real            beta_det;
  vector[V]       gamma_det;
  // Continuous model ----------------------------------------------------------
  vector[N_years] Y;
  vector[SS]      S;
  real            beta;
  vector[V]       gamma;
  real<lower=0>   sigma;
}
model {
  // Detection model, logit link -----------------------------------------------
  // Likelihood
  for (i in 1:N) Detect[i] ~ bernoulli_logit(Y_det[year[i]] + S_det[station[i]] + beta_det*depth[i] + gamma_det[vessel[i]]);
  // Priors
  Y_det     ~ normal(0, 1);
  S_det     ~ normal(0, 1);
  beta_det  ~ normal(0, 1);
  gamma_det ~ normal(0, 1);
  // Continuous model ----------------------------------------------------------
  // Likelihood
  vector[N] mu;
  for (i in 1:N) {
    mu[i] = Y[year[i]] + S[station[i]] + beta*depth[i] + gamma[vessel[i]];
    CPUE[i] ~ normal(mu[i], sigma);
  }
  // Priors
  Y     ~ normal(0, 1);
  S     ~ normal(0, 1);
  beta  ~ normal(0, 1);
  gamma ~ normal(0, 1);
  sigma ~ gamma(0.01, 0.01);
}
generated quantities {
//  vector[N_years] preds;
  vector[N_years] index;
//  vector[N_years] mu_pred;
  real<lower=0,upper=1> theta;
// Computes probability of encounter 
  for (i in 1:N) theta = inv_logit(Y_det[year[i]] + S_det[station[i]] + beta_det*depth[i] + gamma_det[vessel[i]]);

 // Computes model predictions and calculates index by adding year random effects to predictions
   for (i in 1:N_years) {
     //mu_pred[i] = Y[year[i]] + S[station[i]] + beta*depth[i] + gamma[vessel[i]];
     //preds[i]   = normal_rng(mu_pred[i], sigma);
     index[i]   = CPUE[i] + Y[i];
   }
}




















