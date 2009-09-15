awk 'BEGIN{ pi=3.14159; N=10; for(i=0;i<=N;i++) print i,cos(i/N*pi);}'
