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

<b>Error Management<b>
To propgate errors throughout the application - we have ChallengeTVError which implements the LocalizedError protocol

<b>Project Structure<b>
ChallengeTV - root folder...
Contains AppDelegate and launch story board... info.plist etc...
- Error folder contains our error management
- Utilities - contains for the most part useful extensions for String, Date, DateFormatter etc..
- NetworkCommunication - contains our low level network management calls
- Model - contains our actual data model structs/classes
- API - contains our TVAPI class which provides access to the TVMAZE api in this case...
- Service - contains our TVService classes
- UI contains anything related to the UI
  - DetailViewController
	- HomeViewController
	- SizingUtils - contains a utility class for providing sizes for cells etc..
	- Views - contains our cell classes and XIBs (I like using XIBs for cells rather than embedding them in story boards, it makes it easier to use cells in multiple screens later on)

<b> PODS <b>

SDWebImage is the only pod used in this project so far...

<b> Future Considerations <b>


It would be nice to implement this same app as MVVM - the HomeViewModel could take some of the work away from the view controller - and could be an observable... using the new Combine framework from apple, or RxSwift... would be interesting to compare.
