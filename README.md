<b>ChallengeTV</b>

<u>Overview:</u>

The ChallengeTV application will consume APIs provided by TVMAZE (https://www.tvmaze.com/api) land display scheduled TV shows to the user.

It will support the following features:

	•	It will be a universal app that will run on both iPad and iPhone.
	•	It will display a listing of the current week’s (Monday-Sunday) shows on networks in
	•	the United States (network code: US)
	•	It will group events by day and sort them by start time
	•	The show cell’s will display the show poster, name, start time, date, and network directly in the
	•	list without having to tap on a the show
	•	The user will also be able to see the following details (when available) on a particular show.
	⁃	o season number
	⁃	o episode number
	⁃	o show summary
	⁃	o cast
	⁃	o genre
	⁃	o duration

<u>Architecture:</u>
The ChallengeTV application will utilize a Model View Controller Architecture as it's overall structure.


<b><u>Model Layer</u></b>

The model layer will contain/use the following components:

<b>NetworkCommunication</b> - this module will be implemented as a singleton and will be available to any other module requiring it - it will maintain one network operation queue for processing requests.

<b>Models:</b>
Schedule - the schedule model will be the top level model that will contain TVEvents (aka Shows, Episodes etc)
TVEvent - an event will represent a tv show and will contain any necessary sub-models necessary for parsing the incoming response from the server.
Cast - will contain an array of CastMembers for a shows
CastMember - will contain specific information about that person - image, name, who they play in the show.

<b>TVAPI</b> - this module will be responsible for using the NetworkCommunication module to communicate with the TVMAZE api. It will receive appropriate filtering parameters (eg. country, date) and parse resulting JSON data into our Schedule model. It will operate asynchronously using a completion block to either return an error or our populated model. It will also support retrieving cast members for a show.

<b>TVService</b>  - Since a TV Schedule is a living model which can change at any time this part of the model layer will be called a "Service". Since it will stay alive and perform functions periodically on behalf of the rest of the application.

This module will be responsible for determining the time window that schedules need to be fetched for (Current week Monday to Sunday for example). It will also be responsible for managing any caches. It will also allowing fetching of cast members for shows and caching if necessary.

It will be responsible for notifying any observers of updates to the data in the cache… if the time window changes for instance.

It is an observable singleton - if an entity wishes to be updated when the schedule changes that entity can subscribe to the TVService. At the moment, the TVService updates its schedule every night at midnight. It will also schedule retries if there is no network connectivity. Observers are notified of changes to the current schedule as well as any errors that may occur.

This Architecture will allow for more sophisticated features to be implemented in the future, like...

Notifying interested parties of shows ending so a realtime schedule or "ON NOW" section could be added.
If the TV API backend has a ping it could send via a web socket when updates occur the schedule could refresh based on that.
Persisting data in between launches etc… right now iOS' on board caching seems to work well with the TVMAZE api - it caches for 60 minutes.

<b>Controller Layer</b>
There will be two view controllers in this application:

	HomeViewController
		- HomeViewController will be the main view controller for the application.
		- It will be responsible for initiating requests to the TVService portion of the model and receiving models that will be used to populate the various views. More on this in the view section.
		- The HomeViewController will also be responsible for controlling any filtering of the data seen in it's screen which includes showing, hiding and communicating with the search bar also seen on this screen.
		- It will also take care of pushing the details view controller onto the screen as well as passing it any model data it may require to show details.
		- It will act as the datasource and delegate to all collection views contained within it.

	DetailViewController
		- The DetailViewController will be responsible for rendering TVEvent data onto the screen. It will also be responsible for communicating with the model layer's TVService to fetch cast data which is not contained in the event data returned by the schedule api.

<b> View Layer </b>

<b>HomeView</b>
The HomeView is made up of 1 main view container.
That view container contains...
  - 1 top view used to hold a search bar.
	- 1 collection view which will be vertical scrolling.
	- That collection view will host cells that will act as shelf rows.
	- Each day of the week will have it's own section.
	- Each of the shelf row cells will hold 1 horizontal collection View
	- The horizontal collection view will be made up of cells that will represent tv shows

<b>Error Management</b>
To propgate errors throughout the application - we have ChallengeTVError which implements the LocalizedError protocol

<b>Project Structure</b>
ChallengeTV - root folder...
Contains AppDelegate and launch story board... info.plist etc...
- Error folder contains our error management
- Utilities - contains for the most part useful extensions for String, Date, DateFormatter etc..
- NetworkCommunication - contains our low level network management calls
- Model - contains our actual data model structs/classes
- API - contains our TVAPI class which provides access to the TVMAZE api in this case...
  - MockServer - contains everything needed to run the local mock server which provides
	  consistent predictable data to support UNIT and UI testing.
- Service - contains our TVService classes
- UI contains anything related to the UI
  - DetailViewController
	- HomeViewController
	- SizingUtils - contains a utility class for providing sizes for cells etc..
	- Views - contains our cell classes and XIBs (I like using XIBs for cells rather than embedding them in story boards, it makes it easier to use cells in multiple screens later on)

<b> PODS </b>

pod 'SDWebImage', '~> 5.0' is used for loading and caching images...
pod 'OHHTTPStubs/Swift' is used to facilitate testing

<b> Dependancy Management </b>
I am using CocoaPods on this project

<b> General Usage </b>
- The application will display 7 rows of data which will always be the current week starting from Monday...
- The top bar contains a search filters
- To show or hide the search filter scroll up or down
- To fiter shows in the home screen type - it will filter character by character by both show name and network name... not episode name...
- To view more detail about the show tap the show cells
- To view details about the cast, scroll through the cast at the bottom of the details page, if you don't see any, then there were none for that show.

<b> Manual Tests </b>

- The following tests should be performed on various iPad and iOS devices.
- launch app
- click on details
- close details
- observe date on shelf row - click details and ensure that date of asset matches (NOTE: the tvmaze API was observed to produce an air date of one day back for the first show in the list - the actual starttime date is correct)
- Enter the name of a show into the filter bar - the list should reflect any network or show containing the characters you type - for example, if you type CBS, you should only see shows that are on the CBS network - unless the title for a show also contains the characters CBS.
- open the details page for a show that has cast (eg. Days of our lives) verify that you can see the cast
- go back to the home screen - rotate from portrait to landscape - the UI should maintain it's integrity and look good in either orientation
- open the details screen, rotate the device from portrait to landscape - the UI should adjust where the poster is located to suit landscape or portrait
- open details - ensure that we see:
  1) the season and episode information "S3:E10"
	2) Ensure that we see the episode titled
	3) Ensure that we see the show titled
	4) Ensure that we see genres
	5) Ensure that we see the premiered dates
	6) Ensure that we can see the summary - NOTE - we truncate to 4 lines a feature would have to be added to allow full details to be shown when the details are tapped IF they are truncated.
	7) Ensure that the cast is visible
	NOTE: In all cases above it is possible some shows may be missing data that was not returned by the API. Cast is a good example, not all shows have cast data with TVMAZE's api.
- Test that schedule turns over if we switch the date... this was tested manually by setting the refresh timer to 300 seconds, then manually setting the date on the device... a real test on a Sunday night has not been performed yet.

<b>Automated Tests</b>

	Overview: Automated testing is supported by a MockServer that is configured to have 7 end points which serve up consistent predictable data.

	The TVAPI has a flag (useMockData) that can be set to true to use the mock end point.

	The TVService also has a flag (also useMockData) that flips the flag on the TVAPI when set.

	The UI tests set an application parameter that is passed to the app to let it know it should be running with mock data.

	For existing and future unit tests the mock data can be turned on or off as needed by simply setting the flag on the TVService instance.

	Automated UI tests...

	There are two automated UI tests...

		1) func testRowDataAndDetailsDataIntegrity() - this test ensures that each row has the correct data - the test itself was tested by introducing a bug intentionally (and previously unintentionally :) - into the HomeViewController -
		collectionViewCell.setCollectionViewDataSourceDelegate(dataSourceDelegate: self, forRow: indexPath.section) - was passed the row instead of the section - the row is actually the section in our case, not the row. NOTE: Cast testing is limited to one show - swamp thing.

		2) func testFiltering() - this test filters for swamp - ensures that another known show that should not be there is not there, then launches details for swamp, ensure the correct show is opened, closes details, then enters Nbc into the filter ensures there are no CBS shows in the list and ensures Nbc shows ARE in the list.


	Automated Unit tests

		1) func testTVServiceObservableAndFiltering() - this tests that an observer subscribed to the TVService will indeed receive a notification that a schedule is available. It also tests our filtering extension on ScheduleList. (These tests could be broken down but in the interest of time I left them combined)

		2) testServiceCastFetch - tests the cast fetch on the TVService and API - it also ensures that we get Will Patton who is a known cast member for the show we are fetching for.

		3) testNetworkCommunication - tests our network NetworkCommunication class to ensure it can receive parsable JSON data. Again, this is combining JSON deserialization with straight network communication and could be refactored into smaller more meaningful chunks.

<b> Future Considerations </b>


It would be nice to implement this same app as MVVM - the HomeViewModel could take some of the work away from the view controller - and could be an observable... using the new Combine framework from apple, or RxSwift... would be interesting to compare.
