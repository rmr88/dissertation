# Data Appendix

This appendix describes specifics of all data sources to be used in the proposed dissertation.

Many of the analyses in the proposed dissertation will require similar data sources. Since the data used will be similar across chapters, I describe all of my proposed data sources here in the introduction. In each chapter, I will refer back to this section for specific details rather than repeating those details.

## Legislator and Bill Data

Data on bills comprise the main dependent variables for my analyses. As mentioned above, legislator ideologies can be measured using roll call votes or cosponsorship. I will collect data on bills and roll call votes from GovTrack (www.govtrack.us), an organization that compiles and standardizes data from various official records in a format that is easily usable by researchers and private citizens. GovTrack also has legislator-level data on committee membership, leadership positions, and partisanship. Cosponsorship data is available from either GovTrack or from James Fowler's website.[^1] Where it is appropriate to use roll-call based scaled ideology scores, I will use the common space DW-NOMINATE scores available on Keith Poole's website, voteview.com. I plan to conduct at least some analyses using both data on both the House and Senate, with exceptions noted in the chapters as appropriate.

It is also necessary, for some of my analyses, to identify the policy issues/ topics covered by specific bills. For this, I use the Policy Agendas Project data collected by Frank Baumgartner and Bryan Jones.[^2] This data is available for all bills between the 80th and 113th Congresses.

At some points in the study, it will be useful to have data on state legislators. One readily available data source for state legislator ideology is Boris Shor and Nolan McCarty's American Legislatures Project, which uses roll call voting and a recurring survey of state legislators to obtain scaled ideal point estimates for all state legislators on a single scale. The data are described in more detail in @Shor2010, and are available online from http://americanlegislatures.com/.

*[Other data on state legislators can be described here as necessary.]*

## Public Opinion

Measures of public opinion will also be obtained from a few different sources. Large-scale surveys provide actual public opinion data that is representative of voters at the state level, which is useful for analyses of representation by Senators. I plan to use two such surveys. The Cooperative Congressional Election Study (CCES) is an Internet-based survey that began in 2006 and was conducted annually until 2012. The Annenberg National Election Surveys (NAES) was fielded in 2000, 2004, and 2008. I will be looking through the codebooks for specific items that will be useful in my project. In addition to survye data, I also plan to use the big-data based ideal point estimates from @Xing2014.

## Election Returns

For analyses involving presidential vote share and party competition in a state or district, I will need election returns. For district-level measures, I will need to use either available precinct- or county-level reports aggregated up to congressional districts. To aggregate county-level returns, I will follow the methodology used in @Ansolabehere2001 for combining county election results into districts. My initial source of precinct-level data for most elections over the last fifteen years is the "Precinct-Level Election Data" project of Steven Ansolabehere, Maxwell Palmer, and Amanda Lee, available at http://hdl.handle.net/1902.1/21919. State-level returns are easily obtained from the FEC and other official and academic sources. Precinct- and county-level data are both easily aggregated to the state level. In any cases where I need state-level data for which I do not have precinct data, I will pick a source that is most convenient for my purposes.

## Issue Publics

Data on the size of various issue publics will be collected at the state and, where possible, congressional district levels. For doctors, I will use the CMS' Medicare Provider Utilization and Payment Data for 2012, which contains practice information for all physicians and provider organizations that billed Medicare that year. Since almost all providers in the country bill Medicare at least once per year, this data covers virtually all physicians. I geocode the practice location information to ascertain the congressional district in which the provider practices. This yields a count of providers practicing in each congressional district. I will use similar data on hospitals (still to be obtained, but likely from CMS or another government agency like HHS or CDC).

Data on Medicare and Medicaid enrollees by state might be available from CMS or another agency. If not, I can try to use Census data on age and income to infer enrollment rates in Medicare and Medicaid respectively. Another possibility is the Census Bureau's Small Area Health Insurance Estimates, which give insurance status estimates (based on modeling techniques) in states and counties. The SAHIE data also gives estimates of the uninsured, another issue public I plan to examine. Another option for measuring the number uninsured is model estimates in the Catalist data.

*[If possible, I would also look at patients with chronic diseases, cancer, etc. as issue publics. I will need to explore data options for this; perhaps CDC has something, or maybe the websites of the various organized groups have some estimates.]*
	
## Campaign Finance and Lobbying

Campaign finance and data will be collected from opensecrets.org, the website of the Center for Responsive Politics (CRP). CRP takes their data from the FEC and groups it by industry/ advocacy group type and, for campaign contributions, by candidates. Specifically, I will collect campaign contribution data from physician groups (like the AMA); hospital industry groups (like AHA); insurance inductry groups (ex, AHIP); advocacy groups that represent particular patient populations such as seniors (AARP), Medicaid enrollees, and perhaps chronic disease patients; other medical industry groups such as PHrMA; and major party committees and leadership PACs. These data will be collected for all candidates in relevant election cycles. I will also collect lobbying expenditures by these groups for relevant congresses.

## Other Data

Legislator partisanship data is available from a number of sources, including the GovTrack bill and roll call data. To collect whatever demographic information is determined to be necessary for analysis, I will look first at Census Bureau offerings. If that fails, I would turn next to the Catalist dataset.


[^1]: Fowler and his coauthors, Andrew Waugh and Yunkyu Sohn, collected cosponsorship data for the 93rd-108th Congresses for some of their own published work. The data are described on Fowler's website, http://jhfowler.ucsd.edu/cosponsorship.htm and in his peer-reviewed articles [@Fowler2006a, @Fowler2006b].

[^2]: Policy Agendas Project data was collected by Frank R. Baumgartner and Bryan D. Jones, with the support of National Science Foundation grant numbers SBR 9320922 and 0111611, and were distributed through the Department of Government at the University of Texas at Austin. The data and more information is available from the project's website, http://www.policyagendas.org/.
