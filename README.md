<b>ChallengeTV</b>

<bu>Overview:</bu>

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

Architecture:

Model Layer

The model layer will contain/use the following components:

NetworkCommunication - this module will be implemented as a singleton and will be available to any other module requiring it - it will maintain one network operation queue for processing requests.

Models:
Schedule - the schedule model will be the top level model that will contain events (aka Shows, Episodes etc)
Event - an event will represent a tv show and contain any necessary sub-models necessary TBD.

TVAPI - this module will be responsible for using the NetworkCommunication module to communicate with the TVMAZE api. It will receive appropriate filtering parameters (eg. country, date) and parse resulting JSON data into our Schedule model. It will operate asynchronously using a completion block to either return an error or our populated model. It will also support retrieving cast members for a show.

TVService  - this module will be responsible for determining the time window that schedules need to be fetched for. It will also be responsible for managing any caches. It will also allowing fetching of cast members for shows and caching if necessary.

It will be responsible for notifying any observers of updates to the data in the cache… if the time window changes for instance.

In the future - it could handle things like…
Notifying interested parties of shows ending.
Persisting data in between launches etc…
