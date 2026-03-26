chrome.action.onClicked.addListener(async () => {
  const extensionUrl = chrome.runtime.getURL('index.html#/options');
  const existingTabs = await chrome.tabs.query({url: `${chrome.runtime.getURL('index.html')}*`});

  if (existingTabs.length > 0) {
    const tab = existingTabs[0];
    await chrome.tabs.update(tab.id, {active: true, url: extensionUrl});
    if (tab.windowId !== undefined) {
      await chrome.windows.update(tab.windowId, {focused: true});
    }
    return;
  }

  await chrome.tabs.create({url: extensionUrl});
});
