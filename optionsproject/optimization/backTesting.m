function backTesting
feb=Dynamic('D20170117T150000','D20170217T150000',1,100000)
feb=feb.run;
mar=Dynamic('D20170217T150000','D20170317T150000',1,feb.histPort.D20170216T150000.payoff(2343.01))
mar=mar.run;
apr=Dynamic('D20170321T150000','D20170421T150000',1,mar.histPort.D20170316T150000.payoff(2383.71))
apr=apr.run;
may=Dynamic('D20170421T150000','D20170519T150000',1,apr.histPort.D20170420T150000.payoff(2354.74))
may=may.run;
june=Dynamic('D20170519T150000','D20170616T150000',1,may.histPort.D20170518T150000.payoff(2371.37))
june=june.run;
july=Dynamic('D20170621T150000','D20170721T150000',1,june.histPort.D20170615T150000.payoff(2431.24))
july=july.run;
aug=Dynamic('D20170724T150000','D20170818T150000',1,july.histPort.D20170720T150000.payoff(2467.40))
aug=aug.run;
sep=Dynamic('D20170818T150000','D20170915T150000',1,aug.histPort.D20170817T150000.payoff(2427.64))
sep=sep.run;
oct=Dynamic('D20170920T150000','D20171020T150000',1,sep.histPort.D20170914T150000.payoff(2495.67))
oct=oct.run;
nov=Dynamic('D20171020T150000','D20171117T150000',1,oct.histPort.D20171019T150000.payoff(2567.56))
nov=nov.run;


[febMark febSpot febUtility febVol]=feb.getMarkToMarket;
[marMark marSpot marUtility marVol]=mar.getMarkToMarket;
[aprMark aprSpot aprUtility aprVol]=apr.getMarkToMarket;
[mayMark maySpot mayUtility mayVol]=may.getMarkToMarket;
[juneMark juneSpot juneUtility juneVol]=june.getMarkToMarket;
[julyMark julySpot julyUtility julyVol]=july.getMarkToMarket;
[augMark augSpot augUtility augVol]=aug.getMarkToMarket;
[sepMark sepSpot sepUtility sepVol]=sep.getMarkToMarket;
[octMark octSpot octUtility octVol]=oct.getMarkToMarket;
[novMark novSpot novUtility novVol]=nov.getMarkToMarket;

mark=[febMark marMark aprMark mayMark juneMark julyMark augMark sepMark octMark novMark nov.histPort.D20171116T150000.payoff(2582.94)];
spot=[febSpot marSpot aprSpot maySpot juneSpot julySpot augSpot sepSpot octSpot novSpot 2582.94];
partitions=[length(febMark) length(marMark) length(aprMark) length(mayMark) length(juneMark) length(julyMark) length(augMark) length(sepMark) length(octMark) length(novMark)]
partitions=cumsum(partitions)

ax1=subplot(2,1,1);
plot(mark);
hold on
markLength=min(mark)-0.1*min(mark):1000:max(mark)+0.1*max(mark);
ylength=1:1000:15*10^7;
for i=1:length(partitions)
plot([partitions(i)*ones(1,length(markLength))],markLength);
end
axis([0 inf min(markLength) max(markLength)]);
ax2=subplot(2,1,2);
plot(spot);
hold on
spotLength=min(spot)-0.05*min(spot):10:max(spot)+0.05*max(spot);
ylength=2200:1:2600;
for i=1:length(partitions)
plot([partitions(i)*ones(1,length(spotLength))],spotLength)
end
axis([0 inf min(spotLength) max(spotLength)])

figure
plot(log(mark/mark(1)))
hold on
plot(log(spot/spot(1)))
logMarkLength=min(log(mark/mark(1)))-0.25*min(log(mark/mark(1))):0.01:max(log(mark/mark(1)))+0.25*max(log(mark/mark(1)));
for i=1:length(partitions)
plot([partitions(i)*ones(1,length(logMarkLength))],logMarkLength)
end
axis([0 inf min(logMarkLength) max(logMarkLength)])

save feb feb
save mar mar
save apr apr
save may may
save june june
save july july
save aug aug
save sep sep
save oct oct
save nov nov


nov.plotHistPortfolio('D20171116T150000')
sep.plotHistPortfolio('D20170914T150000')
plot(2000:3000,sep.histPort.D20170914T150000.payoff(2000:3000),'displayName','payoff on D20170914T150000')
hold on
%plot(2000:3000,100000*ones(1,length(2000:3000)))
plot(2000:3000,sep.histPort.D20170913T150000.computeMarkToMarket(0)*ones(1,length(2000:3000)),'displayName','mark-to-market on D20170913T150000')
plot(2500*ones(1,length(0:10000:14*10^5)),0:10000:14*10^5,'displayName','spot on D20170914T150000')
plot(2495.67*ones(1,length(0:10000:14*10^5)),0:10000:14*10^5,'displayName','openning price on D20170915T150000')

end
