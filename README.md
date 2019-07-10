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

<b>TVService</b>  - this module will be responsible for determining the time window that schedules need to be fetched for. It will also be responsible for managing any caches. It will also allowing fetching of cast members for shows and caching if necessary.

It will be responsible for notifying any observers of updates to the data in the cache… if the time window changes for instance.

In the future - it could handle things like…
Notifying interested parties of shows ending.
Persisting data in between launches etc…

<b>Controller Layer</b>
There will be two view controllers in this application:

	<b>HomeViewController</b>
		- HomeViewController will be the main view controller for the application.
		- It will be responsible for initiating requests to the TVService portion of the model and receiving models that will be used to populate the various views. More on this in the view section.
		- The HomeViewController will also be responsible for controlling any filtering of the data seen in it's screen which includes showing, hiding and communicating with the search bar also seen on this screen.
		- It will also take care of pushing the details view controller onto the screen as well as passing it any model data it may require to show details.
		- It will act as the datasource and delegate to all collection views contained within it.

	<b>DetailViewController</b>
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
