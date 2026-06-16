/// A generic event emitted by a procedural scene sound.
///
/// The framework does not assign product meaning to the event. Apps can map a
/// sound id such as `bell` to visuals, haptics, analytics, or nothing.
class ProceduralSoundEvent {
  /// Creates an event for [soundId].
  const ProceduralSoundEvent({
    required this.soundId,
    required this.intensity,
    this.frequencyHz,
  });

  /// The scene sound that emitted the event.
  final String soundId;

  /// Event strength in `0..1`.
  final double intensity;

  /// Optional pitch/frequency metadata for sounds that have a note.
  final double? frequencyHz;
}
