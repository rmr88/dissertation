# Data Appendix

This appendix describes specifics of all data sources to be used in the proposed dissertation.

Many of the analyses in the proposed dissertation will require similar data sources. Since the data used will be similar across chapters, I describe all of my proposed data sources here in the introduction. In each chapter, I will refer back to this section for specific details rather than repeating those details.

## Party Competition

A few different indices of party competition have been created over the past few decades. In addition to the index I create in chapter 1, I use a few other standard indices found in the literature. Each captures slightly different aspects of party competition. I describe these indices in some detail below.

One of the older and more well-known indices of party competition, the Ranney Index [@Ranney1976], averages its components over a previously selected time span (scholars often use four, six, eight, or ten years). The index is the average of Democratic seat percentage in both state legislative chambers, the percentage of the vote in the last gubernatorial election that went to the Democratic candidate, and the percentage of time (out of the total time used for the index) the Democrats controlled the state legislative and executive branches. This index is used quite frequently in studies of party competition and its effects at the state level, though it is not without shortcomings or criticism. @Holbrook1993 point out that only one part of the index, the gubernatorial election component, takes into account electoral competition between parties in the state, which can result in a lopsided partisan balance in the legislature despite many legislators having won only narrowly. @King1989 finds that the gubernatorial election component of the index is not quite capturing the same dimension as the other parts of the index. Based on findings such as these, it seems the Ranney index is more suited to measurement of party competition in state government, rather than in elections. Some scholars argue the Ranney index is useful for some designs, but care must be taken to use it correctly for the particular study [@Tucker1982; @King1989]. I expect the Ranney index to be somewhat less useful for my analysis, given I am looking at the effects of partisan electoral competition on the actions of members of Congress rather than state officers, though it is still possible that state-level party competition in the government is capturing relevant variation across states.

The district-based measure created by Holbrook and Van Dunk [HVD; -@Holbrook1993] is offered as a deliberate alternative to the Ranney index, incorporating more election information. The HVD index is generated using percentage of the popular vote won by the winning candidate, the winning candidate's margin of victory, whether or not the seat is safe (defined by HVD as a winning candidate receiving at least 55 percent of the popular vote), and whether the race was contested or not. This index is somewhat correlated with the Ranney index, though not perfectly [@Holbrook1993], and that correlation has changed over time, weakening in recent years [@Shufeldt2012]. Again, the HVD index is more closely related to partisan electoral competition in particular than the Ranney index.

Another party competition index, the Major Party Index [MPI; @Ceaser2005], incorporates election results for President, US Congress, and governor in each state, as well as the percentage of seats held by Republicans in the state legislative chambers. All of the vote percentages used are percentage of the two-party vote given to Republicans. Each of the four components is given equal weight in the overall index, with the congressional and legislative components equally subdivided between the lower and upper chambers. Ceaser and Saldin present this index as an improvement on previous indices (both those mentioned above and others not mentioned), because it includes both federal and state election data, accounts for elections not held every two years (such as governor, president, and US Senator) by filling in the most recent vote totals in years when such elections are not held. They justify the use of state legislative seat percentages, rather than vote percentages, because of the difficulty of collecting this data and because of the high number of uncontested state legislative seats, which they argue would skew the index toward less party competition.

## Legislator and Bill Data

Data on bills comprise the main dependent variables for my analyses. As mentioned above, legislator ideologies can be measured using roll call votes or cosponsorship. I will collect data on bills and roll call votes from GovTrack (www.govtrack.us), an organization that compiles and standardizes data from various official records in a format that is easily usable by researchers and private citizens. GovTrack also has legislator-level data on committee membership, leadership positions, and partisanship. Cosponsorship data is available from either GovTrack or from James Fowler's website.[^1] Where it is appropriate to use roll-call based scaled ideology scores, I will use the common space DW-NOMINATE scores available on Keith Poole's website, voteview.com. I plan to conduct at least some analyses using both data on both the House and Senate, with exceptions noted in the chapters as appropriate.

It is also necessary, for some of my analyses, to identify the policy issues/ topics covered by specific bills. For this, I use the Policy Agendas Project data collected by Frank Baumgartner and Bryan Jones.[^2] This data is available for all bills between the 80th and 113th Congresses.

At some points in the study, it will be useful to have data on state legislators. One readily available data source for state legislator ideology is Boris Shor and Nolan McCarty's American Legislatures Project, which uses roll call voting and a recurring survey of state legislators to obtain scaled ideal point estimates for all state legislators on a single scale. The data are described in more detail in @Shor2010, and are available online from http://americanlegislatures.com/.

**[Other data on state legislators will be described here as necessary.]**

## Public Opinion

Measures of public opinion will also be obtained from a few different sources. Large-scale surveys provide actual public opinion data that is representative of voters at the state level, which is useful for analyses of representation by Senators. I plan to use two such surveys. The Cooperative Congressional Election Study (CCES) is an Internet-based survey that began in 2006 and was conducted annually until 2012. The Annenberg National Election Surveys (NAES) began in 2000, and has been fielded every four years since then.

- Use IPs from Catalist
- could supplement with some survey data (CCES and/ or Annenberg) on major bills
- also, presidential vote share
- perhaps not relevant/ feasible for this paper, but has anyone ever used state-level elections to measure ideology in some sort of composite, factor analysis with pres. vote? (many issues with comparing state parties across states)

## Election Returns

- FEC
- Any other sources, specifically by district?
- State-level data?

## Issue Publics

- doctors (geo-coded CMS PUF practice data)
- uninsured (Catalist)
- Medicare/ Medicaid enrollees (Catalist has Medicare; could check CMS; also, could use Census age/ income profiles as proxies, or the Census SAE data)
	-could even use amount of Medicare/ Medicaid funding going to state (district?)
- hospitals in the district (could try to get that from CMS, HHS, or CDC)
- any way to get at cancer patients, etc.?
	
## Campaign Finance

- from CRP
- provider groups (doctors, hospitals, other providers)
- payers
- patient advocacy groups (esp. Medicaid/ low-income groups, AARP, etc.)
- what about devices, pharma, ancillary services, etc.?
- Party committees (state and federal), leadership PACs

## Other Data

- MC partisanship data
- income (Census?)
- race (Census?)

[^1]: Fowler and his coauthors, Andrew Waugh and Yunkyu Sohn, collected cosponsorship data for the 93rd-108th Congresses for some of their own published work. The data are described on Fowler's website, http://jhfowler.ucsd.edu/cosponsorship.htm and in his peer-reviewed articles [@Fowler2006a, @Fowler2006b].

[^2]: Policy Agendas Project data was collected by Frank R. Baumgartner and Bryan D. Jones, with the support of National Science Foundation grant numbers SBR 9320922 and 0111611, and were distributed through the Department of Government at the University of Texas at Austin. The data and more information is available from the project's website, http://www.policyagendas.org/.
