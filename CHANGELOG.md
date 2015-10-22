# v0.3.10
* Include :environment when passing through to remote
* Update local bundle contents for development

# v0.3.8
* Provide support for :cwd using remote process
* Import QueueStream for easier event streaming

# v0.3.6
* Wait for network availability on remote process
* Use locked async on message transmission

# v0.3.4
* Pass remote process timeout through if available

# v0.3.2
* Store configuration in thread data for safer deferrals
* Add helpers to support remote command processing

# v0.3.0
* Update to build off latest jackal

# v0.2.22
* [feature] event generation helpers
* [enhancement] automatic event generation on start, complete, and finalize

# v0.2.20
* [enhancement] Add test scaffold generator
* [removal] Rest API module removed from utils

# v0.2.18
* [fix] Allow prerelease strings to match when end of string

# v0.2.16
* [fix] Force error data type when message is `failed`

# v0.2.14
* Adjust timing of payload formatter applications

# v0.2.12
* Support customized URL pathing for jobs

# v0.2.10
* Add validation on working path generation and removal

# v0.2.8
* Fix: syntax error on prerelease string match

# v0.2.6
* Apply formatters prior to finalization deliveries
* Add utility method for prerelease check
* Add common module for REST
* Sync startup and configuration with jackal

# v0.2.4
* Add service registration support

# v0.2.2
* Add support for content unpack within payloads
* Update job linking generation
* Import cipher module from fission-data
* Auto extract account configuration from payload if available
* Clean up constant reset for callbacks

# v0.2.0
* Automatically push orphan messages to router
* Add support for payload formatters (automatic)
* Auto-register jackal callbacks into fission
* Integrate bogo libs and remove mixlib-cli
* Disable message forward on frozen payloads
* Freeze configuration after setup
* Add compat fields to payload so jackals work correctly

# v0.1.6
* Include message ID on incoming message logging
* Stub account data when validator is disabled not data

# v0.1.2
* See commit log. I'm too lazy to list

# v0.1.0
* Initial release
