// Service Worker สำหรับ Web Push Notifications — ไปนำแหน่
self.addEventListener('push', (event) => {
  if (!event.data) return;

  let data;
  try {
    data = event.data.json();
  } catch {
    data = { title: 'ไปนำแหน่', body: event.data.text() };
  }

  const options = {
    body: data.body || '',
    icon: data.icon || '/favicon.ico',
    badge: data.badge || '/favicon.ico',
    data: { url: data.url || '/' },
    vibrate: [200, 100, 200],
    tag: data.tag || 'painamnae-notification',
    renotify: true,
  };

  event.waitUntil(
    self.registration.showNotification(data.title || 'ไปนำแหน่', options)
  );
});

// เมื่อผู้ใช้คลิกที่ notification → เปิดหน้าที่เกี่ยวข้อง
self.addEventListener('notificationclick', (event) => {
  event.notification.close();

  const targetUrl = event.notification.data?.url || '/';

  event.waitUntil(
    clients.matchAll({ type: 'window', includeUncontrolled: true }).then((windowClients) => {
      // ถ้ามีหน้าต่างเปิดอยู่ → focus แล้ว navigate
      for (const client of windowClients) {
        if (client.url.includes(self.location.origin)) {
          client.navigate(targetUrl);
          return client.focus();
        }
      }
      // ถ้าไม่มี → เปิดหน้าต่างใหม่
      return clients.openWindow(targetUrl);
    })
  );
});
