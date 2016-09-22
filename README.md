#CourseSourcer
##Fearlessly connecting ideas.

<br>
<br>

###Summary
CourseSourcer is a way for students to connect anonymously to help each other's success. Rather than worrying about an individual's reputation, CourseSourcer simply puts ideas in a central location in the form of messages, notes, and assignment details so that everyone can be kept in the loop.

###Circumstances
I worked on CourseSourcer over the Summer of 2016 mainly on my commute to and from work every day. I never got as far as I wanted with the project to put it in the App Store, but I came close enough to want to publish what I've done. So whether it's a showcase of my largest individual project, an idea someone else wants to contribute to, or just some example code someone wants to incorporate into their own project, do what you please.

###Most Significant Flaws

- Images are simply defaults, and cannot be changed or sent to the server
- You can create an account, but your email will not be sent a confirmation, you'll just be automatically confirmed
- Once you log out you can not be logged back in

###Technologies
- Frontend
	- iOS (Swift 3)
	- Realm
	- Pods
		- Alamofire
		- AlamofireImage
		- JSQMessages
		- RealmSwift
		- SwiftyJSON
- Backend
	- Node.js (CoffeeScript)
	- MongoDB
	- npm
		- bcrypt
		- body-parser		
		- express
		- lodash
		- mongoo
		- mongoose-id-validator
		- mongoose-timestamp
		- rekuire

###@TODO

####Fixes
- Retrieve with limits and based on lastId
- White status bar on loading screen
- Transition from homeschedule to assignment with the navigationbar should be the correct color
- Home screen crude gesture to schedule
- Groupmessages topleft should be <Back instead of <Course
- Groupmessage by admin distinction
- Make add bar button item on home a picture of a classroom with a +
- Limit devices on backend (this has to be done in login route)
- Links don’t work in messages
- Make sure we’re validating on updates too

####Additions
- Customize group message cells 
	- Validity button
	- user_handle labels on messages if admin
- Image picker
- Email already Registered
- '+' right item button on classmates to invite people
- Sending attachments through messages
- Live message updating
- Course pic in search
- Reorder courses
- “Blocked From”
- Favoriting/Hiding posts on frontend
- Ability to hide from classmates list

