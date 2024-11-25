import mido
import sys

def analyze_midi(file_path):
    try:
        # Load the MIDI file
        midi_file = mido.MidiFile(file_path)
        
        # Extract note data
        notes = []
        for i, track in enumerate(midi_file.tracks):
            print(f"Track {i}: {track.name}")
            for msg in track:
                if not msg.is_meta:  # Skip meta messages
                    if msg.type == 'note_on' or msg.type == 'note_off':
                        notes.append(msg.note)
        
        return notes

    except Exception as e:
        print(f"Error processing MIDI file: {e}")
        return []

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python analyze_midi.py <path_to_midi_file>")
    else:
        midi_path = sys.argv[1]
        notes_array = analyze_midi(midi_path)
        print("Array of note numbers:", notes_array)