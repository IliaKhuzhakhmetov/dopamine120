/// The five ambient layers the focus screen mixes, each driven by its own knob.
///
/// Order matches the knob row in the reference UI.
enum SoundLayer {
  /// Low sustained drone — the bed of the mix.
  drone,

  /// Filtered-noise rainfall.
  rain,

  /// Slow sub-bass breathing pulse.
  pulse,

  /// Sparse bell pings scheduled at random.
  bell,

  /// Strange high-frequency cicada chatter.
  cicada,
}
