importScripts("https://www.gstatic.com/firebasejs/10.7.1/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/10.7.1/firebase-messaging-compat.js");

// 🟢 तुमच्या firebase_options.dart मधील खरी माहिती इथे भरली आहे:
firebase.initializeApp({
  apiKey: "AIzaSyDSvxTCE16t-dvPn5FldxtidIAkJxjOvYs",
  authDomain: "loginsetup-6f413.firebaseapp.com",
  projectId: "loginsetup-6f413",
  storageBucket: "loginsetup-6f413.firebasestorage.app",
  messagingSenderId: "21224449328",
  appId: "1:21224449328:web:cf83d80abf2a4163f154f5"
});

const messaging = firebase.messaging();

// बॅकग्राउंड नोटिफिकेशनसाठी
messaging.onBackgroundMessage(function(payload) {
  console.log("Background Message:", payload);
  const notificationTitle = payload.notification.title;
  const notificationOptions = {
    body: payload.notification.body,
    icon: "/icons/Icon-192.png"
  };
  return self.registration.showNotification(notificationTitle, notificationOptions);
});