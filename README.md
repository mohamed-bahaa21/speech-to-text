Everything now is faster, and needs to be easier, and writing by voice is much faster than writing by hand.
so the first think was to use MDN Web voice-to-text, it’s a browser responsibility feature that will allow user to record his voice, then it will transcribe to text in the HTML input.
but this approach has limits starting from the browser compatibility, until customizing our own User experience, that we want our User to have.
And so we needed to break the task into three parts:
first is User recording his voice or uploading a sound file.
second is transcribing the voice into text.
third is to use AI to review the transcribed text for any syntax errors.

[1] User voice.
And so the approach now to have a form with mainly 3 parts, first is hidden input that will point to the audio file, second part is the upload audio file input, and third part is record voice button.
And whether User chooses to upload a file or record his own live voice, the hidden input value will be set to the url that last received from one of the other two parts.
Since first and second parts are clear,

Third part is to implement audio recording using the Recorder.js library.
When the page is loaded, event listeners are added to the ‘Record Audio’ button. When this button is clicked, the application requests access to the user’s microphone. If access is granted, recording begins. Clicking the button again stops the recording.
After recording is stopped, the audio is exported as a WAV file and a URL is created for it.
This URL is set as the source for an audio element, allowing the user to playback their recording.
The recorded audio file is also added to the audio_file input field in the form.

The form does not automatically submit after recording.
The user must manually submit the form, at which point the audio file will be included in the form data. The form data can then be processed by the server, such as by transcribing the audio file.
and this allows user to either record his own voice right now, or to upload an already existing audio he has, that he wishes to use.

[2] Transcribing voice to text.
the current approach is to have a pre-trained model and upload it into memory, then to use background jobs to queue up to send requests over to the model that we have running in our memory.
after the audio is submitted by the user there are 3 steps that user can see, first is pending, which waits until the audio gets queued up, then processing, in which the audio file is being transcribed, then completed.
we don’t have other steps for now.
audio files are deleted after the processing is completed in the current stage, as we are using ActiveStorage and we don’t want to overwhelm the local disk storage, but later we can send the files to S3 or any other 3rd party storage service.

[3] AI to fix syntax errors.
I didn’t add the 3rd part yet, but a notice for now, you won’t find syntax errors most of the time with big models.
So this part is to compensate dropping the big size that bigger models will take from memory, with AI endpoint to fix syntax errors that could occur from small models.
And although there are API endpoints for transcribing voice, as for fixing syntax, but the latter is way cheaper.

Separation of voice-to-text module
since voice-to-text will be used in different parts, as an example: writing a description, then it needs to be in a separated module.
So we created Audio model that has polymorphic association with any other table, then each submitted audio file will go to the audio controller to be processed and return the result transcribed text, then it will be returned to the Associated_Table controller to add it to the chosen attribute parameter.

Conditional Initialization
The transcription process is conditionally initialized by checking the WHISPER environment variable. This prevents unnecessary memory allocation by making sure that an instance of the Transcriber class is only fully initialized and resources allocated when WHISPER is set to true. This avoids potential memory leaks from creating unused transcription instances.

Singleton Approach.
A singleton pattern is used to make sure that only one instance of the Transcriber class (TRANSCRIBER) is created and used throughout the application. This prevents the creation of multiple subprocesses, which would consume additional CPU and memory, and avoids race conditions, by maintaining consistent state across all transcription operations.

Thanks in advance.
