document.addEventListener('DOMContentLoaded', () => {

  /* ── Element references ── */
  const themeBtn       = document.getElementById('themeBtn');
  const themeSun       = document.getElementById('themeSun');
  const themeMoon      = document.getElementById('themeMoon');
  const langToggle     = document.getElementById('langToggle');
  const muscleButtons  = Array.from(document.querySelectorAll('.muscle-btn'));
  const siteTitle      = document.getElementById('siteTitle');
  const heroTitle      = document.getElementById('heroTitle');
  const heroDesc       = document.getElementById('heroDesc');
  const selectedTitle  = document.getElementById('selectedTitleText');
  const panelLabel     = document.getElementById('panelLabel');
  const panelIcon      = document.querySelector('.panel__title-icon');
  const videosContainer= document.getElementById('videos');

  /* ── Exercise data ── */
  const exercises = {
    "Chest": [
      { id: "a9vL6BsgkPg", title: "Bench Press — Chest Builder" },
      { id: "fGm-ef-4PVk", title: "Incline Dumbbell Press" }
    ],
    "Back": [
      { id: "jLvqKgW-_G8", title: "Barbell Row — Back Thickness" },
      { id: "2eA2Koq6pTI", title: "Lat Pulldown" }
    ],
    "Biceps": [
      { id: "ykJmrZ5v0Oo", title: "Barbell Curl — Biceps Peak" }
    ],
    "Triceps": [
      { id: "2-LAMcpzODU", title: "Triceps Pushdown" }
    ],
    "Shoulders": [
      { id: "SgyUoY0IZ7A", title: "Overhead Press — Shoulders" }
    ],
    "Legs": [
      { id: "8zWDuWKdBZU", title: "Barbell Squat — Legs" }
    ],
    "Abs": [
      { id: "ad4zfM2ioD8", title: "Ab Crunch — Core" }
    ]
  };

  /* ── Translations ── */
  const t = {
    en: {
      siteTitle:      "Muscle Wiki",
      heroTitle:      "Muscle Wiki",
      heroDesc:       "Interactive muscle wiki & exercise videos.",
      selectedNone:   "None",
      selectedPrefix: "",
      backToFitify:   "Back to Fitify",
      emptyText:      "Choose a muscle group to see exercises",
      panelLabel:     "Selected Muscle",
      watchYT:        "Watch on YouTube",
      exercise:       "Exercise"
    },
    ar: {
      siteTitle:      "ويكي عضلات",
      heroTitle:      "ويكي العضلات",
      heroDesc:       "ويكي عضلي تفاعلي وفيديوهات تمارين.",
      selectedNone:   "لا شيء",
      selectedPrefix: "",
      backToFitify:   "العودة إلى فيتيفاي",
      emptyText:      "اختر مجموعة عضلية لعرض التمارين",
      panelLabel:     "العضلة المحددة",
      watchYT:        "شاهد على يوتيوب",
      exercise:       "تمرين"
    }
  };

  /* ── State ── */
  let theme = localStorage.getItem('fitify_theme') ||
    (window.matchMedia?.('(prefers-color-scheme: dark)').matches ? 'dark' : 'light');
  let lang = localStorage.getItem('fitify_lang') || 'en';
  let currentMuscleKey = null;

  /* ── Init ── */
  applyTheme();
  applyLang();
  wire();

  /* ────────────────────────────────────────────
     Theme
  ──────────────────────────────────────────── */
  function applyTheme() {
    if (theme === 'dark') {
      document.documentElement.removeAttribute('data-theme');
      themeSun.style.display = 'block';
      themeMoon.style.display = 'none';
    } else {
      document.documentElement.setAttribute('data-theme', 'light');
      themeSun.style.display = 'none';
      themeMoon.style.display = 'block';
    }
    localStorage.setItem('fitify_theme', theme);
  }

  /* ────────────────────────────────────────────
     Language
  ──────────────────────────────────────────── */
  function applyLang() {
    const l = t[lang];
    siteTitle.textContent   = l.siteTitle;
    heroTitle.textContent   = l.heroTitle;
    heroDesc.textContent    = l.heroDesc;
    panelLabel.textContent  = l.panelLabel;

    const backText = document.getElementById('backBtnText');
    if (backText) backText.textContent = l.backToFitify;

    const emptyText = document.getElementById('emptyText');
    if (emptyText) emptyText.textContent = l.emptyText;

    // Update muscle button labels
    muscleButtons.forEach(btn => {
      const label = btn.querySelector('.muscle-btn__label');
      if (label) label.textContent = lang === 'en' ? btn.dataset.en : btn.dataset.ar;
    });

    // Update selected title
    if (currentMuscleKey) {
      const activeBtn = muscleButtons.find(b => b.dataset.en === currentMuscleKey);
      if (activeBtn) {
        selectedTitle.textContent = lang === 'en' ? activeBtn.dataset.en : activeBtn.dataset.ar;
      }
    } else {
      selectedTitle.textContent = l.selectedNone;
    }

    langToggle.checked = (lang === 'ar');
    document.documentElement.dir = lang === 'ar' ? 'rtl' : 'ltr';
    localStorage.setItem('fitify_lang', lang);
  }

  /* ────────────────────────────────────────────
     Build video cards
  ──────────────────────────────────────────── */
  function renderVideos(muscleKey) {
    const vids = exercises[muscleKey] || [];
    if (!vids.length) {
      videosContainer.innerHTML = `
        <div class="videos__empty">
          <svg width="56" height="56" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.2" stroke-linecap="round" stroke-linejoin="round" style="opacity:.35">
            <polygon points="23 7 16 12 23 17 23 7"/>
            <rect x="1" y="5" width="15" height="14" rx="2" ry="2"/>
          </svg>
          <p>No exercises available</p>
        </div>`;
      return;
    }

    videosContainer.innerHTML = vids.map((v, i) => {
      const thumb = `https://img.youtube.com/vi/${v.id}/hqdefault.jpg`;
      const ytLink = `https://www.youtube.com/watch?v=${v.id}`;
      return `
        <div class="video-card" style="animation-delay:${i * .07}s" data-video-id="${v.id}">
          <div class="video-card__thumb">
            <img src="${thumb}" alt="${v.title}" loading="lazy" />
            <div class="video-card__play">
              <div class="video-card__play-circle">
                <svg width="22" height="22" viewBox="0 0 24 24" fill="#fff"><polygon points="6 3 20 12 6 21 6 3"/></svg>
              </div>
            </div>
            <div class="video-card__info">
              <div class="video-card__name">${v.title}</div>
            </div>
          </div>
          <div class="video-card__body">
            <span class="video-card__meta">${t[lang].exercise} ${i + 1}</span>
            <a href="${ytLink}" target="_blank" rel="noopener" class="video-card__cta" onclick="event.stopPropagation()">
              <svg width="14" height="14" viewBox="0 0 24 24" fill="currentColor"><path d="M19.615 3.184c-3.604-.246-11.631-.245-15.23 0C.488 3.45.029 5.804 0 12c.029 6.185.484 8.549 4.385 8.816 3.6.245 11.626.246 15.23 0C23.512 20.55 23.971 18.196 24 12c-.029-6.185-.484-8.549-4.385-8.816zM9 16V8l8 4-8 4z"/></svg>
              ${t[lang].watchYT}
            </a>
          </div>
        </div>`;
    }).join('');

    // Add click handlers for inline play
    videosContainer.querySelectorAll('.video-card').forEach(card => {
      card.addEventListener('click', () => openVideoModal(card.dataset.videoId));
    });
  }

  /* ────────────────────────────────────────────
     Video modal
  ──────────────────────────────────────────── */
  function openVideoModal(videoId) {
    // Create modal if not exists
    let modal = document.querySelector('.video-modal');
    if (!modal) {
      modal = document.createElement('div');
      modal.className = 'video-modal';
      modal.innerHTML = `
        <div class="video-modal__inner">
          <button class="video-modal__close" aria-label="Close">&times;</button>
          <iframe allowfullscreen></iframe>
        </div>`;
      document.body.appendChild(modal);

      modal.addEventListener('click', (e) => {
        if (e.target === modal || e.target.closest('.video-modal__close')) {
          closeVideoModal();
        }
      });
      document.addEventListener('keydown', (e) => {
        if (e.key === 'Escape') closeVideoModal();
      });
    }

    const iframe = modal.querySelector('iframe');
    iframe.src = `https://www.youtube.com/embed/${videoId}?autoplay=1`;
    requestAnimationFrame(() => modal.classList.add('open'));
  }

  function closeVideoModal() {
    const modal = document.querySelector('.video-modal');
    if (modal) {
      modal.classList.remove('open');
      setTimeout(() => {
        const iframe = modal.querySelector('iframe');
        if (iframe) iframe.src = '';
      }, 300);
    }
  }

  /* ────────────────────────────────────────────
     Event wiring
  ──────────────────────────────────────────── */
  function wire() {
    // Theme toggle
    themeBtn.addEventListener('click', () => {
      theme = theme === 'dark' ? 'light' : 'dark';
      applyTheme();
    });

    // Language toggle
    langToggle.addEventListener('change', () => {
      lang = langToggle.checked ? 'ar' : 'en';
      siteTitle.classList.add('fade');
      setTimeout(() => {
        applyLang();
        // Re-render videos if a muscle is selected
        if (currentMuscleKey) renderVideos(currentMuscleKey);
        siteTitle.classList.remove('fade');
      }, 200);
    });

    // Muscle buttons
    muscleButtons.forEach(btn => {
      btn.addEventListener('click', () => {
        muscleButtons.forEach(x => x.classList.remove('active'));
        btn.classList.add('active');

        currentMuscleKey = btn.dataset.en;
        const displayName = lang === 'en' ? btn.dataset.en : btn.dataset.ar;
        selectedTitle.textContent = displayName;

        // Show label + icon with animation
        panelLabel.classList.add('visible');
        panelIcon.classList.add('visible');

        renderVideos(currentMuscleKey);
      });

      // Track mouse for ripple effect
      btn.addEventListener('mousemove', (e) => {
        const rect = btn.getBoundingClientRect();
        btn.style.setProperty('--x', ((e.clientX - rect.left) / rect.width * 100) + '%');
        btn.style.setProperty('--y', ((e.clientY - rect.top) / rect.height * 100) + '%');
      });
    });
  }

});