import speech_recognition as sr
import os
from dotenv import load_dotenv
from openai import OpenAI
from gtts import gTTS
# Load environment variables from .env file
load_dotenv()

client = OpenAI()

def listen_and_print():
    # Initialize the recognizer
    recognizer = sr.Recognizer()
    
    # Use the default microphone as the audio source
    try:
        with sr.Microphone() as source:
            print("Adjusting for ambient noise... Please wait.")
            recognizer.adjust_for_ambient_noise(source, duration=1)
            print("Listening... (Speak now!)")

            while True:
                try:
                    # Listen for audio
                    # phrase_time_limit=None allows it to listen until silence
                    audio = recognizer.listen(source, timeout=None)
                    
                    print("Recognizing...", end="\r")
                    
                    # Recognize speech using Google Speech Recognition
                    # show_all=False returns just the string
                    text = recognizer.recognize_google(audio)
                    if "tony" in text.lower():
                        prompt = text.replace("tony", "")

                        response = client.responses.create(
                            model="gpt-5-nano",
                            input=prompt,
                        )
                        print("\nTony Genarating:")
                        language = 'en'

                        myobj = gTTS(text=response.output_text, lang=language, slow=False)
                        myobj.save("welcome.mp3")

                        # Playing the converted file
                        os.system("mpg123 welcome.mp3")
                    else:
                        print(f"ignoring:\t {text}")
                    
                except sr.WaitTimeoutError:
                    pass # Just keep listening
                except sr.UnknownValueError:
                    # print("Could not understand audio") # Optional: reduce noise in output
                    pass
                except sr.RequestError as e:
                    print(f"Could not request results; {e}")
                except KeyboardInterrupt:
                    print("\nStopping...")
                    break
                    
    except OSError as e:
        print(f"Error accessing microphone: {e}")
        print("Please ensure you have a working microphone.")

if __name__ == "__main__":
    listen_and_print()
