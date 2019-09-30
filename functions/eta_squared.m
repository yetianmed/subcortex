function eta=eta_squared(z)
%Compute similiarity between rows of z 
%z=rand(10,100); 
%z(2,:)=z(1,:)+randn(1,100)*0.3; 

N=size(z,1); 
p=size(z,2);
eta=zeros(N,N); 
for i=1:N
    mu=(repmat(z(i,:),N,1)+z)/2; 
    mu_bar=mean(mu,2); 
    eta(:,i)=sum((repmat(z(i,:),N,1)-mu).^2 + (z-mu).^2,2); 
    eta(:,i)=1 - eta(:,i) ./ sum((repmat(z(i,:),N,1)-mu_bar).^2 + (z-mu_bar).^2,2); 
end

%imagesc(eta)
    