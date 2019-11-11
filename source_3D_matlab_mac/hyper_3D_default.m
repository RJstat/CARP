function x = hyper_3D_default(obs, dimension, prunning, sigma_hat)
tic;
if nargin == 2
    prunning = true; 
end 

if prunning 
    eta_list = [0.3, 0.4, 0.5]; 
else
    eta_list = [0]; 
end 

total_level = log2(numel(obs));
idx = (1:2:numel(obs));
a = (obs(idx) - obs(idx + 1)) ./ sqrt(2);
%sigma_hat = mad(a(:), 1) * 1.4826;
%sigma_hat = 0.0001;
% beta = 1; last_rho = 0.05; alpha = 0; last_tau = 1/(sigma_hat^2); eta = 0.5;
% x(1) = log(beta); x(2) = log(last_rho) + log(2) * beta * total_level;
% x(4) = log(alpha);
% x(5) = log(last_tau); x(3) = -log(1/eta - 1); x(6) = log(sigma_hat);


% last_tau, last_rho, alpha, eta 
n_value = [3, 3, 1, numel(eta_list)]; 
n_grid = prod(n_value); 

% last_tau = repmat(2.^(-5:5), 1, n_grid/n_value(1)); 
last_tau = 1/(sigma_hat^2) .* repelem((1:3)./10, 1, n_grid/n_value(1)); 
last_rho = repmat(repelem((1:3)./10,1,n_grid/n_value(1)/n_value(2)), 1, n_value(1)); 
beta = 1; 
alpha = repmat(0.5, 1, n_grid/n_value(3)) ; 
eta = repmat(eta_list, 1, n_grid/n_value(4));  
adjust = zeros([1, n_grid]); 
% hyper: log(beta), log(C) = log(last_rho) + log(2) * beta * total_level
%        -log(1/eta - 1), log(alpha), log(last_tau) - alpha * total_level *
%        log(2)
hyper = [log(beta) + adjust; 
    log(last_rho) + log(2) * beta * total_level; 
    -log(1./eta - 1) + adjust; 
    log(alpha) + adjust; 
    log(last_tau) + alpha .* total_level .* log(2); 
    log(sigma_hat) + adjust]; 

%poolobj = parpool(3);
% parfor i=1:3
%     ll_value(i) = treeLikelihood(obs, dimension, hyper(:,i)); 
% end
%delete(poolobj)
%ll_value = treeLikelihood(obs, dimension, hyper);
% sprintf('selected: (alpha, beta, last_tau * sigma * sigma, last_rho, eta) = (%.2f, %.2f, %.2f, %.2f, %.2f)', ...
%     alpha(v), 1, last_tau(v) * sigma_hat^2, last_rho(v), eta(v))
%[~,v] = max(ll_value);
x = hyper(:, 2); 
toc;
end
