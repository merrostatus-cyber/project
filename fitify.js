// Fitify v6.0 - Unified Dashboard & Premium Water Tracker

document.addEventListener('DOMContentLoaded', () => {
  // --- Data ---
  const quotes = {
    en: [
      { text: "The secret of getting ahead is getting started.", author: "Mark Twain" },
      { text: "Your body achieves what your mind believes.", author: "Unknown" },
      { text: "Success starts with self-discipline.", author: "Unknown" },
      { text: "Don't wish for it, work for it.", author: "Unknown" },
      { text: "The only bad workout is the one that didn't happen.", author: "Unknown" }
    ],
    ar: [
      { text: "سر التقدّم هو أن تبدأ.", author: "مارك توين" },
      { text: "جسمك يحقق ما تؤمن به عقلك.", author: "مجهول" },
      { text: "النجاح يبدأ بالانضباط الذاتي.", author: "مجهول" },
      { text: "لا تتمنى ذلك، اعمل من أجله.", author: "مجهول" },
      { text: "التمرين السيئ الوحيد هو الذي لم يحدث.", author: "مجهول" }
    ]
  };

  const exercisesDb = {
    beginner: [
      { name: "Brisk Walking", description: "Walk at a fast pace for 30 minutes daily.", instructions: "Maintain good posture, swing arms naturally, wear comfortable shoes." },
      { name: "Bodyweight Squats", description: "3 sets of 10 reps. Strengthens legs and core muscles.", instructions: "Feet shoulder-width apart, lower until thighs parallel to ground, keep knees behind toes." }
    ],
    intermediate: [
      { name: "Running Intervals", description: "Alternate 1 minute running with 1 minute walking for 20 minutes.", instructions: "Start with 5 intervals, gradually increase intensity and duration." },
      { name: "Dumbbell Rows", description: "3 sets of 12 reps per arm. Strengthens back muscles.", instructions: "Bend knees slightly, keep back straight, pull elbow up to torso." }
    ],
    advanced: [
      { name: "HIIT Circuit", description: "30 seconds each: burpees, jump squats, mountain climbers. 3 rounds.", instructions: "Maintain proper form even when fatigued, rest 1 minute between rounds." },
      { name: "Deadlifts", description: "4 sets of 8 reps with proper weight. Full-body strength builder.", instructions: "Keep back straight, lift with legs not back, control the movement." }
    ]
  };

  const dietPlans = {
    en: {
      underweight: ["Increase calorie intake with healthy foods like nuts, avocados, and whole grains", "Eat 5-6 smaller meals", "Include protein with every meal"],
      normal: ["Maintain balanced meals with protein, complex carbs, and healthy fats", "Fill half your plate with colorful vegetables", "Stay hydrated"],
      overweight: ["Create a moderate calorie deficit", "Focus on lean proteins and fiber-rich foods", "Reduce refined carbohydrates"],
      obese: ["Consult with a doctor or nutritionist", "Start with small, sustainable changes", "Focus on whole, unprocessed foods"]
    },
    ar: {
      underweight: ["زد من السعرات الصحية — مكسرات، أفوكادو، وحبوب كاملة", "كل 5-6 وجبات صغيرة", "أضف بروتين في كل وجبة"],
      normal: ["حافظ على وجبات متوازنة مع البروتين والكربوهيدرات والدهون الصحية", "اجعل نصف طبقك خضار", "اشرب الماء"],
      overweight: ["عجز معتدل في السعرات", "ركز على البروتينات والألياف", "قلل الكربوهيدرات السريعة"],
      obese: ["استشر طبيبًا", "تغييرات صغيرة ومستدامة", "أطعمة غير مصنعة"]
    }
  };

  const translations = {
    en: {
      personalInfoTitle: "Personal Details",
      measurementsTitle: "Body Measurements",
      genderLabel: "Gender:",
      weightLabel: "Weight (kg):",
      heightLabel: "Height (cm):",
      ageLabel: "Age:",
      fitnessLevelLabel: "Fitness Level:",
      activityLabel: "Activity Level:",
      neckLabel: "Neck (cm):",
      waistLabel: "Waist (cm):",
      hipLabel: "Hip (cm) - Female only:",
      userNameLabel: "Name:",
      calculateBtn: "Calculate Only",
      exportBtn: "📥 Download PDF",
      generateBtn: "Generate Plan",
      resultsTitle: "Your Fitness Dashboard",
      thMetric: "Metric",
      thResult: "Result",
      thStatus: "Status / Category",
      rowBmiTitle: "BMI",
      rowIdealWeightTitle: "Ideal Weight",
      rowBodyfatTitle: "Body Fat %",
      rowCaloriesTitle: "TDEE (Daily Calories)",
      waterTitle: "💧 Water Intake Tracker",
      waterGoalLabel: "Goal (ml):",
      sedentaryOpt: "Sedentary (little/no exercise)",
      lightOpt: "Light (1-3 days/week)",
      moderateOpt: "Moderate (3-5 days/week)",
      activeOpt: "Active (6-7 days/week)",
      veryActiveOpt: "Very Active (athlete/physical job)",
      refreshBtn: "Refresh",
      languageBtn: "عربي",
      maleText: "Male",
      femaleText: "Female",
      optBeginner: "Beginner",
      optIntermediate: "Intermediate",
      optAdvanced: "Advanced",
      healthPlaceholder: "Any injuries or health concerns...",
      exerciseTitle: "Exercise Plan",
      dietTitle: "Nutrition Plan",
      feedbackTitle: "Your Feedback",
      submitBtn: "Submit Feedback",
      // Categories
      catUnderweight: "Underweight",
      catNormal: "Normal",
      catOverweight: "Overweight",
      catObese: "Obese",
      fatEssential: "Essential Fat",
      fatAthletic: "Athletic",
      fatFitness: "Fitness",
      fatAcceptable: "Acceptable",
      fatObese: "Obese",
      // Advice
      cutAdvice: "Cut: ",
      maintainAdvice: "Maintain: ",
      bulkAdvice: "Bulk: "
    },
    ar: {
      personalInfoTitle: "التفاصيل الشخصية",
      measurementsTitle: "قياسات الجسم",
      genderLabel: "النوع:",
      weightLabel: "الوزن (كجم):",
      heightLabel: "الطول (سم):",
      ageLabel: "العمر:",
      fitnessLevelLabel: "مستوى اللياقة:",
      activityLabel: "مستوى النشاط:",
      neckLabel: "الرقبة (سم):",
      waistLabel: "الخصر (سم):",
      hipLabel: "الورك (سم) - للإناث فقط:",
      userNameLabel: "الاسم:",
      calculateBtn: "إحسب فقط",
      exportBtn: "📥 تحميل (PDF)",
      generateBtn: "إنشاء الخطة",
      resultsTitle: "لوحة نتائج اللياقة الخاصة بك",
      thMetric: "المعيار",
      thResult: "النتيجة",
      thStatus: "الحالة / التصنيف",
      rowBmiTitle: "مؤشر كتلة الجسم",
      rowIdealWeightTitle: "الوزن المثالي",
      rowBodyfatTitle: "نسبة الدهون",
      rowCaloriesTitle: "السعرات اليومية",
      waterTitle: "💧 متتبع شرب الماء",
      waterGoalLabel: "الهدف (مل):",
      sedentaryOpt: "خامل (بدون تمرين)",
      lightOpt: "خفيف (1-3 أيام/أسبوع)",
      moderateOpt: "معتدل (3-5 أيام/أسبوع)",
      activeOpt: "نشط (6-7 أيام/أسبوع)",
      veryActiveOpt: "نشط جداً",
      refreshBtn: "تحديث",
      languageBtn: "English",
      maleText: "ذكر",
      femaleText: "أنثى",
      optBeginner: "مبتدئ",
      optIntermediate: "متوسط",
      optAdvanced: "متقدم",
      healthPlaceholder: "أية إصابات...",
      exerciseTitle: "خطة التدريب",
      dietTitle: "خطة التغذية",
      feedbackTitle: "ملاحظاتك",
      submitBtn: "إرسال",
      // Categories
      catUnderweight: "نحيف",
      catNormal: "طبيعي",
      catOverweight: "زيادة وزن",
      catObese: "سمنة",
      fatEssential: "دهون أساسية",
      fatAthletic: "رياضي",
      fatFitness: "لياقة",
      fatAcceptable: "مقبول",
      fatObese: "سمنة",
      // Advice
      cutAdvice: "تخسيس: ",
      maintainAdvice: "ثبات: ",
      bulkAdvice: "تضخيم: "
    }
  };

  const $ = id => document.getElementById(id);
  let currentLang = localStorage.getItem('language') || 'en';
  if (localStorage.getItem('darkMode') === 'enabled') document.body.classList.add('dark-mode');

  function displayRandomQuote() {
    const list = quotes[currentLang] || quotes.en;
    const i = Math.floor(Math.random() * list.length);
    if ($('quoteText')) $('quoteText').textContent = list[i].text;
    if ($('quoteAuthor')) $('quoteAuthor').textContent = `- ${list[i].author}`;
  }

  // ==================== PREMIUM WATER TRACKER ====================
  // Ensure we migrate existing water intake properly if it was stored in liters
  let storedWater = parseFloat(localStorage.getItem('waterIntakeMl'));
  if (isNaN(storedWater)) {
    const oldWaterLiters = parseFloat(localStorage.getItem('waterIntake'));
    storedWater = !isNaN(oldWaterLiters) ? oldWaterLiters * 1000 : 0;
  }

  let waterIntake = storedWater;
  let waterGoal = parseInt(localStorage.getItem('waterGoalMl')) || 2500;

  function updateWaterUI() {
    const circle = $('waterCircleProgress');
    const pctText = $('waterPercentage');
    const statusText = $('waterStatus');
    const goalInput = $('dailyWaterGoal');

    // Clamp at 100% physically, but logic stores actual amount
    const percent = Math.min((waterIntake / waterGoal) * 100, 100).toFixed(0);

    if (circle) {
      // Circumference = 339.292 for r=54
      const circumference = 339.292;
      const offset = circumference - (percent / 100) * circumference;
      circle.style.strokeDashoffset = offset;
    }

    if (pctText) pctText.textContent = `${percent}%`;
    if (statusText) statusText.textContent = `${waterIntake} / ${waterGoal} ml`;
    if (goalInput && goalInput.value != waterGoal) goalInput.value = waterGoal;

    localStorage.setItem('waterIntakeMl', waterIntake);
    localStorage.setItem('waterGoalMl', waterGoal);
  }

  function modifyWater(amount) {
    waterIntake = Math.max(0, waterIntake + amount); // Prevent going below zero
    updateWaterUI();
    if (waterIntake >= waterGoal && amount > 0) {
      // alert user on reaching goal
    }
  }

  // ==================== UNIFIED CALCULATIONS ====================
  function performAllCalculations() {
    const gender = $('gender').value;
    const weight = parseFloat($('weight').value);
    const height = parseFloat($('height').value);
    const age = parseInt($('age').value, 10);
    const neck = parseFloat($('neck').value);
    const waist = parseFloat($('waist').value);
    const hip = parseFloat($('hip').value);
    const activity = parseFloat($('activityLevel').value);

    if (!weight || !height || !age) {
      alert(currentLang === 'ar' ? 'من فضلك أدخل الوزن والطول والعمر' : 'Please enter Weight, Height, and Age at least.');
      return;
    }

    const t = translations[currentLang];

    // Show results table
    $('results').style.display = 'block';
    if (!$('results').classList.contains('fade-up')) $('results').classList.add('fade-up');

    // 1. BMI
    const hM = height / 100;
    const bmi = +(weight / (hM * hM)).toFixed(1);
    let bmiCat = '', bmiCls = '';
    if (bmi < 18.5) { bmiCat = t.catUnderweight; bmiCls = 'badge-warning'; }
    else if (bmi < 25) { bmiCat = t.catNormal; bmiCls = 'badge-normal'; }
    else if (bmi < 30) { bmiCat = t.catOverweight; bmiCls = 'badge-warning'; }
    else { bmiCat = t.catObese; bmiCls = 'badge-danger'; }

    $('resBmiValue').textContent = bmi;
    $('resBmiStatus').textContent = bmiCat;
    $('resBmiStatus').className = `badge ${bmiCls}`;

    // 2. Ideal Weight
    let ideal;
    if (gender === 'male') ideal = (height - 100 - ((height - 150) / 4)).toFixed(1);
    else ideal = (height - 100 - ((height - 150) / 2.5)).toFixed(1);
    $('resIdealWeightValue').textContent = `${ideal} kg`;
    $('resIdealWeightStatus').textContent = "—";

    // 3. Body Fat (Requires Neck & Waist)
    if (neck > 0 && waist > 0 && (gender === 'male' || hip > 0)) {
      let bodyFat = 0;
      let fatCat = '', fatCls = '';

      if (gender === 'male') {
        bodyFat = 86.010 * Math.log10(waist - neck) - 70.041 * Math.log10(height) + 36.76;
        bodyFat = Math.max(5, Math.min(45, Math.round(bodyFat * 10) / 10));

        if (bodyFat < 8) { fatCat = t.fatEssential; fatCls = 'badge-normal'; }
        else if (bodyFat < 15) { fatCat = t.fatAthletic; fatCls = 'badge-normal'; }
        else if (bodyFat < 20) { fatCat = t.fatFitness; fatCls = 'badge-normal'; }
        else if (bodyFat < 25) { fatCat = t.fatAcceptable; fatCls = 'badge-warning'; }
        else { fatCat = t.fatObese; fatCls = 'badge-danger'; }
      } else {
        bodyFat = 163.205 * Math.log10(waist + hip - neck) - 97.684 * Math.log10(height) - 78.387;
        bodyFat = Math.max(10, Math.min(50, Math.round(bodyFat * 10) / 10));

        if (bodyFat < 14) { fatCat = t.fatEssential; fatCls = 'badge-normal'; }
        else if (bodyFat < 21) { fatCat = t.fatAthletic; fatCls = 'badge-normal'; }
        else if (bodyFat < 28) { fatCat = t.fatFitness; fatCls = 'badge-normal'; }
        else if (bodyFat < 32) { fatCat = t.fatAcceptable; fatCls = 'badge-warning'; }
        else { fatCat = t.fatObese; fatCls = 'badge-danger'; }
      }

      $('resBodyfatValue').textContent = `${bodyFat}%`;
      $('resBodyfatStatus').textContent = fatCat;
      $('resBodyfatStatus').className = `badge ${fatCls}`;
    } else {
      $('resBodyfatValue').textContent = "Incomplete data";
      $('resBodyfatStatus').textContent = "";
      $('resBodyfatStatus').className = "";
    }

    // 4. Daily Calories (TDEE)
    let bmr;
    if (gender === 'male') bmr = 88.362 + (13.397 * weight) + (4.799 * height) - (5.677 * age);
    else bmr = 447.593 + (9.247 * weight) + (3.098 * height) - (4.330 * age);

    const tdee = Math.round(bmr * activity);
    $('resCaloriesValue').textContent = `${tdee} kcal`;

    // Status text for TDEE contains goals
    $('resCaloriesStatus').innerHTML = `
      ${t.cutAdvice} <strong>${tdee - 500}</strong> cal<br>
      ${t.maintainAdvice} <strong>${tdee}</strong> cal<br>
      ${t.bulkAdvice} <strong>${tdee + 300}</strong> cal
    `;

    // Health Advice Warning
    const healthIssues = $('healthIssues').value.trim();
    if (healthIssues) {
      $('healthAdvice').textContent = currentLang === 'ar' ? "ملاحظة: بسبب الحالات الصحية المدخلة، ننصح باستشارة طبيب." : "Note: Due to the inputted health conditions, we advise consulting a doctor.";
    } else {
      $('healthAdvice').textContent = '';
    }

    // Scroll smoothly to results
    $('results').scrollIntoView({ behavior: 'smooth' });
  }

  function generatePlan() {
    // If not calculated yet, do it first silently if valid
    if ($('resBmiValue').textContent === '-') performAllCalculations();

    const fitnessLevel = $('fitnessLevel').value;
    const list = exercisesDb[fitnessLevel] || exercisesDb.beginner;

    const exContainer = $('exercises');
    if (exContainer) {
      exContainer.innerHTML = '';
      list.forEach(ex => {
        const el = document.createElement('div');
        el.className = 'exercise-card fade-up';
        el.innerHTML = `<h3>${ex.name}</h3><p>${ex.description}</p><div class="instructions">${ex.instructions}</div>`;
        exContainer.appendChild(el);
      });
    }

    const bmiVal = parseFloat($('resBmiValue').textContent) || 22;
    let dietKey = 'normal';
    if (bmiVal < 18.5) dietKey = 'underweight';
    else if (bmiVal < 25) dietKey = 'normal';
    else if (bmiVal < 30) dietKey = 'overweight';
    else dietKey = 'obese';

    const dietContainer = $('nutritionTips');
    if (dietContainer) {
      dietContainer.innerHTML = '<ul></ul>';
      const dietSource = dietPlans[currentLang];
      if (dietSource[dietKey]) {
        dietSource[dietKey].forEach(tip => {
          const li = document.createElement('li'); li.textContent = tip; dietContainer.querySelector('ul').appendChild(li);
        });
      }
    }
  }

  // ==================== LANGUAGE HANDLING ====================
  function updateLanguage(lang) {
    currentLang = lang;
    document.documentElement.lang = lang;
    document.body.dir = lang === 'ar' ? 'rtl' : 'ltr';
    displayRandomQuote();

    const t = translations[lang];

    // Apply texts dynamically based on ID
    const elIDs = ['personalInfoTitle', 'measurementsTitle', 'userNameLabel', 'genderLabel', 'weightLabel',
      'heightLabel', 'ageLabel', 'fitnessLevelLabel', 'activityLabel', 'neckLabel',
      'waistLabel', 'hipLabel', 'healthIssuesLabel', 'resultsTitle',
      'thMetric', 'thResult', 'thStatus', 'rowBmiTitle', 'rowIdealWeightTitle',
      'rowBodyfatTitle', 'rowCaloriesTitle', 'waterTitle', 'waterGoalLabel',
      'sedentaryOpt', 'lightOpt', 'moderateOpt', 'activeOpt', 'veryActiveOpt',
      'maleOption', 'femaleOption', 'optBeginner', 'optIntermediate', 'optAdvanced',
      'exerciseTitle', 'dietTitle', 'feedbackTitle', 'submitText'];

    // Map IDs manually for exact matches
    if ($('userNameLabel')) $('userNameLabel').textContent = t.userNameLabel;
    if ($('personalInfoTitle')) $('personalInfoTitle').textContent = t.personalInfoTitle;
    if ($('measurementsTitle')) $('measurementsTitle').textContent = t.measurementsTitle;
    if ($('genderLabel')) $('genderLabel').textContent = t.genderLabel;
    if ($('weightLabel')) $('weightLabel').textContent = t.weightLabel;
    if ($('heightLabel')) $('heightLabel').textContent = t.heightLabel;
    if ($('ageLabel')) $('ageLabel').textContent = t.ageLabel;
    if ($('fitnessLevelLabel')) $('fitnessLevelLabel').textContent = t.fitnessLevelLabel;
    if ($('activityLabel')) $('activityLabel').textContent = t.activityLabel;
    if ($('neckLabel')) $('neckLabel').textContent = t.neckLabel;
    if ($('waistLabel')) $('waistLabel').textContent = t.waistLabel;
    if ($('hipLabel')) $('hipLabel').textContent = t.hipLabel;
    if ($('healthIssuesLabel')) $('healthIssuesLabel').textContent = t.healthIssuesLabel;
    if ($('calculateText')) $('calculateText').textContent = t.calculateBtn;
    if ($('exportText')) $('exportText').textContent = t.exportBtn;
    if ($('generateText')) $('generateText').textContent = t.generateBtn;
    if ($('resultsTitle')) $('resultsTitle').textContent = t.resultsTitle;
    if ($('thMetric')) $('thMetric').textContent = t.thMetric;
    if ($('thResult')) $('thResult').textContent = t.thResult;
    if ($('thStatus')) $('thStatus').textContent = t.thStatus;
    if ($('waterTitle')) $('waterTitle').textContent = t.waterTitle;
    if ($('waterGoalLabel')) $('waterGoalLabel').textContent = t.waterGoalLabel;

    // Table rows
    if ($('rowBmiTitle')) $('rowBmiTitle').innerHTML = `<strong>${t.rowBmiTitle}</strong>`;
    if ($('rowIdealWeightTitle')) $('rowIdealWeightTitle').innerHTML = `<strong>${t.rowIdealWeightTitle}</strong>`;
    if ($('rowBodyfatTitle')) $('rowBodyfatTitle').innerHTML = `<strong>${t.rowBodyfatTitle}</strong>`;
    if ($('rowCaloriesTitle')) $('rowCaloriesTitle').innerHTML = `<strong>${t.rowCaloriesTitle}</strong>`;

    // Dropdowns
    if ($('sedentaryOpt')) $('sedentaryOpt').textContent = t.sedentaryOpt;
    if ($('lightOpt')) $('lightOpt').textContent = t.lightOpt;
    if ($('moderateOpt')) $('moderateOpt').textContent = t.moderateOpt;
    if ($('activeOpt')) $('activeOpt').textContent = t.activeOpt;
    if ($('veryActiveOpt')) $('veryActiveOpt').textContent = t.veryActiveOpt;
    if ($('maleOption')) $('maleOption').textContent = t.maleText;
    if ($('femaleOption')) $('femaleOption').textContent = t.femaleText;
    if ($('optBeginner')) $('optBeginner').textContent = t.optBeginner;
    if ($('optIntermediate')) $('optIntermediate').textContent = t.optIntermediate;
    if ($('optAdvanced')) $('optAdvanced').textContent = t.optAdvanced;

    if ($('healthIssues')) $('healthIssues').placeholder = t.healthPlaceholder;
    if ($('exerciseTitle')) $('exerciseTitle').textContent = t.exerciseTitle;
    if ($('dietTitle')) $('dietTitle').textContent = t.dietTitle;
    if ($('feedbackTitle')) $('feedbackTitle').textContent = t.feedbackTitle;
    if ($('submitText')) $('submitText').textContent = t.submitBtn;
    if ($('refreshBtn')) $('refreshBtn').textContent = t.refreshBtn;
    if (document.querySelector('.lang-text')) document.querySelector('.lang-text').textContent = t.languageBtn;

    // Refresh calculations if already populated to translate results
    if ($('resBmiValue') && $('resBmiValue').textContent !== '-') {
      performAllCalculations();
    }

    localStorage.setItem('language', lang);
  }

  // ==================== EVENT LISTENERS ====================
  function initEventListeners() {
    $('darkModeToggle')?.addEventListener('click', () => {
      document.body.classList.toggle('dark-mode');
      localStorage.setItem('darkMode', document.body.classList.contains('dark-mode') ? 'enabled' : 'disabled');
    });

    $('languageToggle')?.addEventListener('click', () => {
      updateLanguage(currentLang === 'en' ? 'ar' : 'en');
    });

    $('refreshBtn')?.addEventListener('click', () => location.reload());

    $('calculateBtn')?.addEventListener('click', performAllCalculations);
    $('exportPdfBtn')?.addEventListener('click', () => {
      let userName = $('userName').value.trim();
      if (!userName) {
        userName = prompt(currentLang === 'ar' ? 'من فضلك أدخل اسمك للتقرير:' : 'Please enter your name for the report:');
        if (!userName) return; // user cancelled
        $('userName').value = userName;
      }

      // Check if calculations exist
      if (!$('resBmiValue') || $('resBmiValue').textContent === '-') {
        performAllCalculations(); // Attempt to calculate first
        if ($('resBmiValue').textContent === '-') return; // still failed inputs
      }

      // Map values into hidden PDF template
      $('pdfName').textContent = userName;
      $('pdfDate').textContent = new Date().toLocaleDateString();
      $('pdfBmiValue').textContent = $('resBmiValue').textContent;
      $('pdfBmiStatus').textContent = $('resBmiStatus').textContent;
      $('pdfFatValue').textContent = $('resBodyfatValue').textContent;
      $('pdfFatStatus').textContent = $('resBodyfatStatus').textContent;
      $('pdfIdealWeight').textContent = $('resIdealWeightValue').textContent;
      $('pdfTdeeValue').textContent = $('resCaloriesValue').textContent;
      $('pdfNeck').textContent = $('neck').value ? $('neck').value + " cm" : "N/A";
      $('pdfWaist').textContent = $('waist').value ? $('waist').value + " cm" : "N/A";

      const element = $('report');
      const container = $('pdfContainer');
      container.style.display = 'block';

      // Temporarily fix body height and overflow to prevent mobile scaling issues
      const originalHeight = document.body.style.height;
      const originalMinHeight = document.body.style.minHeight;
      document.body.style.height = 'auto';
      document.body.style.minHeight = 'auto';

      const opt = {
        margin: 0,
        filename: `fitness_report_${userName.replace(/\s+/g, '_').toLowerCase()}.pdf`,
        image: { type: 'jpeg', quality: 0.98 },
        html2canvas: {
          scale: 2,
          scrollY: 0,
          windowHeight: document.body.scrollHeight
        },
        jsPDF: { unit: 'mm', format: 'a4', orientation: 'portrait' }
      };

      html2pdf().set(opt).from(element).save().then(() => {
        container.style.display = 'none';
        document.body.style.height = originalHeight;
        document.body.style.minHeight = originalMinHeight;
      });
    });
    $('generatePlanBtn')?.addEventListener('click', generatePlan);

    // Water tracker
    document.querySelectorAll('.w-btn.add').forEach(btn => {
      btn.addEventListener('click', (e) => {
        modifyWater(parseInt(e.target.dataset.amount));
      });
    });

    $('removeWaterBtn')?.addEventListener('click', () => { modifyWater(-250); });

    $('dailyWaterGoal')?.addEventListener('change', (e) => {
      const val = parseInt(e.target.value);
      if (val >= 500) { waterGoal = val; updateWaterUI(); }
    });

    // Muscle wiki
    $('muscleWikiBtn')?.addEventListener('click', () => { window.location.href = 'muscle.html'; });

    // Submit Feedback using EmailJS
    $('submitFeedback')?.addEventListener('click', () => {
      const fbInput = $('feedbackInput');
      const fb = fbInput ? fbInput.value.trim() : '';

      if (!fb) {
        alert(currentLang === 'ar' ? 'من فضلك اكتب ملاحظتك قبل الإرسال.' : 'Please enter your feedback prior to submitting.');
        return;
      }

      const btn = $('submitFeedback');
      const originalText = btn.innerHTML;
      btn.innerHTML = currentLang === 'ar' ? 'جاري الإرسال...' : 'Sending...';
      btn.disabled = true;

      const userName = $('userName') ? $('userName').value.trim() : 'Anonymous';

      fetch("https://formsubmit.co/ajax/fitifyfeedback@gmail.com", {
        method: "POST",
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
        body: JSON.stringify({
          _subject: "New Fitify Feedback from " + userName,
          name: userName,
          message: fb,
          date: new Date().toLocaleDateString()
        })
      })
        .then(response => response.json())
        .then(data => {
          alert(currentLang === 'ar' ? 'تم الإرسال! شكراً لملاحظتك!' : 'Sent! Thank you for your feedback!');
          fbInput.value = '';
          btn.innerHTML = originalText;
          btn.disabled = false;
        })
        .catch(error => {
          console.error("FormSubmit Error:", error);
          alert(currentLang === 'ar' ? 'حدث خطأ. يرجى المحاولة لاحقاً.' : 'Error sending feedback. Please try again later.');
          btn.innerHTML = originalText;
          btn.disabled = false;
        });
    });

    // Show/hide hip
    const genderSelect = $('gender');
    const hipGroup = $('hipGroup');
    if (genderSelect && hipGroup) {
      const toggleHip = () => { hipGroup.style.display = genderSelect.value === 'female' ? 'block' : 'none'; };
      genderSelect.addEventListener('change', toggleHip);
      toggleHip();
    }
  }

  // Init
  updateLanguage(currentLang);
  updateWaterUI();
  initEventListeners();
  displayRandomQuote();
});
function generatePDF() {
  const inputs = document.querySelectorAll("input");
  let name = "";
  let weight = "";

  inputs.forEach(inp => {
    if (inp.type === "text" && !name) name = inp.value;
    if (inp.type === "number" && !weight) weight = inp.value;
  });

  document.getElementById("pdfName").innerText = "Name: " + name;
  document.getElementById("pdfWeight").innerText = "Weight: " + weight;

  const element = document.getElementById("pdfReport");
  element.style.display = "block";

  html2pdf().set({
    margin: 0,
    filename: 'fitify-report.pdf',
    html2canvas: { scale: 2 },
    jsPDF: { unit: 'mm', format: 'a4', orientation: 'portrait' }
  }).from(element).save().then(() => {
    element.style.display = "none";
  });
}
