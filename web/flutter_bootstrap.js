{{flutter_js}}
{{flutter_build_config}}

const serviceWorkerVersion = {{flutter_service_worker_version}};

(function () {
  let startupActive = true;

  function showBootstrapError(message) {
    const pre = document.createElement('pre');
    pre.textContent = message;
    pre.style.whiteSpace = 'pre-wrap';
    pre.style.wordBreak = 'break-word';
    pre.style.margin = '0';
    pre.style.padding = '16px';
    pre.style.color = '#f4f7fb';
    pre.style.fontFamily = 'monospace';
    pre.style.fontSize = '12px';
    pre.style.lineHeight = '1.4';

    document.body.innerHTML = '';
    document.body.style.background = '#081018';
    document.body.appendChild(pre);
  }

  function onWindowError(event) {
    if (!startupActive) {
      return;
    }
    const details = event.error && event.error.stack
      ? event.error.stack
      : [event.message, event.filename, event.lineno, event.colno]
          .filter(Boolean)
          .join(' @ ');
    showBootstrapError('Bootstrap error: ' + details);
  }

  function onUnhandledRejection(event) {
    if (!startupActive) {
      return;
    }
    const reason = event.reason && event.reason.stack
      ? event.reason.stack
      : String(event.reason);
    showBootstrapError('Unhandled bootstrap rejection:\n\n' + reason);
  }

  function teardownBootstrapGuards() {
    startupActive = false;
    window.removeEventListener('error', onWindowError);
    window.removeEventListener('unhandledrejection', onUnhandledRejection);
  }

  window.addEventListener('error', onWindowError);
  window.addEventListener('unhandledrejection', onUnhandledRejection);

  _flutter.loader.load({
    config: {
      canvasKitBaseUrl: 'canvaskit/',
    },
    serviceWorkerSettings: {
      serviceWorkerVersion,
    },
    onEntrypointLoaded: async function (engineInitializer) {
      try {
        const appRunner = await engineInitializer.initializeEngine();
        await appRunner.runApp();
        teardownBootstrapGuards();
      } catch (error) {
        showBootstrapError(
          'Flutter engine startup failed:\n\n' +
          (error && error.stack ? error.stack : String(error))
        );
      }
    }
  }).catch(function (error) {
    showBootstrapError(
      'Flutter bootstrap failed:\n\n' +
      (error && error.stack ? error.stack : String(error))
    );
  });
})();
