{{flutter_js}}
{{flutter_build_config}}

// Custom bootstrap: same as Flutter's default, plus removing the HTML
// loading screen from index.html once the app is running.
_flutter.loader.load({
  onEntrypointLoaded: async function (engineInitializer) {
    const appRunner = await engineInitializer.initializeEngine();
    await appRunner.runApp();
    const loading = document.getElementById('loading');
    if (loading) {
      loading.classList.add('done');
      setTimeout(() => loading.remove(), 300);
    }
  },
});
