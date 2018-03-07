[febMark febSpot febUtility febVol]=febCalBS.getMarkToMarket
[marMark marSpot marUtility marVol]=marCalBS.getMarkToMarket
[aprMark aprSpot aprUtility aprVol]=aprCalBS.getMarkToMarket
[mayMark maySpot mayUtility mayVol]=mayCalBS.getMarkToMarket
[juneMark juneSpot juneUtility juneVol]=juneCalBS.getMarkToMarket
[julyMark julySpot julyUtility julyVol]=julyCalBS.getMarkToMarket
markFebCalBS=[febMark marMark aprMark mayMark juneMark julyMark]
spotFebCalBS=[febSpot marSpot aprSpot maySpot juneSpot julySpot]
utilityFebCalBS=[febUtility marUtility aprUtility mayUtility juneUtility julyUtility]
volFebCalBS=[febVol marVol aprVol mayVol juneVol julyVol]
partitionFebCalBS=[length(febMark) length(marMark) length(aprMark) length(mayMark) length(juneMark) length(julyMark)]
partitionFebCalBS=cumsum(partitionFebCalBS);
for i=1:length(partitionFebCalBS)
    hold on
    plot(partitionFebCalBS(i)*ones(1,length(0:1:3*10^5)),0:1:3*10^5)
end

[febMark febSpot febUtility febVol]=febHistMu0BS.getMarkToMarket
[marMark marSpot marUtility marVol]=marHistMu0BS.getMarkToMarket
[aprMark aprSpot aprUtility aprVol]=aprHistMu0BS.getMarkToMarket
[mayMark maySpot mayUtility mayVol]=mayHistMu0BS.getMarkToMarket
[juneMark juneSpot juneUtility juneVol]=juneHistMu0BS.getMarkToMarket
[julyMark julySpot julyUtility julyVol]=julyHistMu0BS.getMarkToMarket
markFebCalBS=[febMark marMark aprMark mayMark juneMark julyMark]
spotFebCalBS=[febSpot marSpot aprSpot maySpot juneSpot julySpot]
utilityFebCalBS=[febUtility marUtility aprUtility mayUtility juneUtility julyUtility]
volFebCalBS=[febVol marVol aprVol mayVol juneVol julyVol]
partitionFebCalBS=[length(febMark) length(marMark) length(aprMark) length(mayMark) length(juneMark) length(julyMark)]