(function () {
  const metadata = {
    title: 'LIVE - Active session',
    artist: 'DOPAMINE120',
    artwork: [{ src: 'icons/Icon-512.png', sizes: '512x512', type: 'image/png' }],
  };

  let audio;

  function assetUrl(path) {
    return new URL(path, document.querySelector('base')?.href || document.baseURI).toString();
  }

  function ensureAudio() {
    if (audio) return audio;

    audio = document.createElement('audio');
    audio.src = assetUrl('media/pwa_audio_anchor.wav');
    audio.loop = true;
    audio.preload = 'auto';
    audio.volume = 0.001;
    audio.setAttribute('playsinline', '');
    audio.style.display = 'none';
    document.body.appendChild(audio);
    return audio;
  }

  function setMediaSession(playbackState) {
    if (!('mediaSession' in navigator)) return;

    navigator.mediaSession.metadata = new MediaMetadata({
      title: metadata.title,
      artist: metadata.artist,
      album: metadata.artist,
      artwork: metadata.artwork.map((item) => ({ ...item, src: assetUrl(item.src) })),
    });
    navigator.mediaSession.playbackState = playbackState;
    setLivePositionState();
    navigator.mediaSession.setActionHandler('play', requestStart);
    navigator.mediaSession.setActionHandler('pause', requestStop);
    navigator.mediaSession.setActionHandler('stop', requestStop);
  }

  function setLivePositionState() {
    if (typeof navigator.mediaSession.setPositionState !== 'function') return;

    try {
      navigator.mediaSession.setPositionState({
        duration: Infinity,
        playbackRate: 1,
        position: 0,
      });
    } catch (_) {
      // Some browsers expose Media Session but reject live position state.
    }
  }

  function requestStart() {
    window.dopamineBackgroundAudio.onStartRequested?.();
    start();
  }

  function requestStop() {
    window.dopamineBackgroundAudio.onStopRequested?.();
    stop();
  }

  async function start() {
    try {
      const anchor = ensureAudio();
      setMediaSession('playing');
      await anchor.play();
    } catch (error) {
      console.warn('Focus LIVE media card could not start.', error);
    }
  }

  async function stop() {
    try {
      if (audio) {
        audio.pause();
        audio.currentTime = 0;
      }
      setMediaSession('paused');
    } catch (error) {
      console.warn('Focus LIVE media card could not stop.', error);
    }
  }

  window.dopamineBackgroundAudio = {
    start,
    stop,
    onStartRequested: null,
    onStopRequested: null,
  };
})();
