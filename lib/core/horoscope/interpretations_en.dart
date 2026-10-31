import 'interpretations.dart';

/// Original English horoscope text library for Drishti.
///
/// Tone rules: balanced and constructive, never fear-based, never promising
/// outcomes ("traditionally", "may", "tends to"), no paid remedies, neutral on
/// gender, caste and religion.
///
/// Key scheme (other languages must use the same keys):
/// ```text
///   period.<daily|weekly|monthly|yearly>       period word ("today")
///   area.<career|money|love|health|mind>       area title
///   planet.<name> / sign.<0-11> / rashi.<0-11> / ordinal.<1-27> / weekday.<0-6>
///   nakshatra.<0-26> / month.<1-12> / date.dm / date.dmy
///   planet.<name>.the                          English only: name with article
///   house.<1-12>                               house themes
///   opener.<area>.<1-5>                        first sentence by area score
///   fx.<planet>.<area>.<pos|neg>               effect clause of a transit
///   transit.vedic / transit.western / transit.solar   sentence templates
///   advice.<area>.<low|mid|high>               closing sentence
///   overall.<1-5>                              overall summary
///   tara.name.<0-8> / tara.text.<0-8>          Tara Bala
///   aspect.<type> / aspect.phrase.<type>       Western aspects
///   reason.* / event.* / why.* / lucky.*       factual explanations
/// ```
const interpretationsEn = HoroscopeTexts('en', _en);

const _en = <String, List<String>>{
  // ---------------------------------------------------------------- basics
  'period.daily': ['today'],
  'period.weekly': ['this week'],
  'period.monthly': ['this month'],
  'period.yearly': ['this year'],

  'area.career': ['Career'],
  'area.money': ['Money'],
  'area.love': ['Love & Relationships'],
  'area.health': ['Health & Energy'],
  'area.mind': ['Mood & Mind'],

  'planet.sun': ['Sun'],
  'planet.moon': ['Moon'],
  'planet.mars': ['Mars'],
  'planet.mercury': ['Mercury'],
  'planet.jupiter': ['Jupiter'],
  'planet.venus': ['Venus'],
  'planet.saturn': ['Saturn'],
  'planet.rahu': ['Rahu'],
  'planet.ketu': ['Ketu'],
  'planet.uranus': ['Uranus'],
  'planet.neptune': ['Neptune'],
  'planet.pluto': ['Pluto'],
  'planet.sun.the': ['the Sun'],
  'planet.moon.the': ['the Moon'],
  'planet.rahu.western': ['the North Node'],
  'planet.ketu.western': ['the South Node'],

  'sign.0': ['Aries'],
  'sign.1': ['Taurus'],
  'sign.2': ['Gemini'],
  'sign.3': ['Cancer'],
  'sign.4': ['Leo'],
  'sign.5': ['Virgo'],
  'sign.6': ['Libra'],
  'sign.7': ['Scorpio'],
  'sign.8': ['Sagittarius'],
  'sign.9': ['Capricorn'],
  'sign.10': ['Aquarius'],
  'sign.11': ['Pisces'],

  'rashi.0': ['Mesha (Aries)'],
  'rashi.1': ['Vrishabha (Taurus)'],
  'rashi.2': ['Mithuna (Gemini)'],
  'rashi.3': ['Karka (Cancer)'],
  'rashi.4': ['Simha (Leo)'],
  'rashi.5': ['Kanya (Virgo)'],
  'rashi.6': ['Tula (Libra)'],
  'rashi.7': ['Vrishchika (Scorpio)'],
  'rashi.8': ['Dhanu (Sagittarius)'],
  'rashi.9': ['Makara (Capricorn)'],
  'rashi.10': ['Kumbha (Aquarius)'],
  'rashi.11': ['Meena (Pisces)'],

  'ordinal.1': ['1st'],
  'ordinal.2': ['2nd'],
  'ordinal.3': ['3rd'],
  'ordinal.4': ['4th'],
  'ordinal.5': ['5th'],
  'ordinal.6': ['6th'],
  'ordinal.7': ['7th'],
  'ordinal.8': ['8th'],
  'ordinal.9': ['9th'],
  'ordinal.10': ['10th'],
  'ordinal.11': ['11th'],
  'ordinal.12': ['12th'],
  'ordinal.13': ['13th'],
  'ordinal.14': ['14th'],
  'ordinal.15': ['15th'],
  'ordinal.16': ['16th'],
  'ordinal.17': ['17th'],
  'ordinal.18': ['18th'],
  'ordinal.19': ['19th'],
  'ordinal.20': ['20th'],
  'ordinal.21': ['21st'],
  'ordinal.22': ['22nd'],
  'ordinal.23': ['23rd'],
  'ordinal.24': ['24th'],
  'ordinal.25': ['25th'],
  'ordinal.26': ['26th'],
  'ordinal.27': ['27th'],

  'weekday.0': ['Sunday'],
  'weekday.1': ['Monday'],
  'weekday.2': ['Tuesday'],
  'weekday.3': ['Wednesday'],
  'weekday.4': ['Thursday'],
  'weekday.5': ['Friday'],
  'weekday.6': ['Saturday'],

  'nakshatra.0': ['Ashwini'],
  'nakshatra.1': ['Bharani'],
  'nakshatra.2': ['Krittika'],
  'nakshatra.3': ['Rohini'],
  'nakshatra.4': ['Mrigashira'],
  'nakshatra.5': ['Ardra'],
  'nakshatra.6': ['Punarvasu'],
  'nakshatra.7': ['Pushya'],
  'nakshatra.8': ['Ashlesha'],
  'nakshatra.9': ['Magha'],
  'nakshatra.10': ['Purva Phalguni'],
  'nakshatra.11': ['Uttara Phalguni'],
  'nakshatra.12': ['Hasta'],
  'nakshatra.13': ['Chitra'],
  'nakshatra.14': ['Swati'],
  'nakshatra.15': ['Vishakha'],
  'nakshatra.16': ['Anuradha'],
  'nakshatra.17': ['Jyeshtha'],
  'nakshatra.18': ['Mula'],
  'nakshatra.19': ['Purva Ashadha'],
  'nakshatra.20': ['Uttara Ashadha'],
  'nakshatra.21': ['Shravana'],
  'nakshatra.22': ['Dhanishta'],
  'nakshatra.23': ['Shatabhisha'],
  'nakshatra.24': ['Purva Bhadrapada'],
  'nakshatra.25': ['Uttara Bhadrapada'],
  'nakshatra.26': ['Revati'],

  'month.1': ['Jan'],
  'month.2': ['Feb'],
  'month.3': ['Mar'],
  'month.4': ['Apr'],
  'month.5': ['May'],
  'month.6': ['Jun'],
  'month.7': ['Jul'],
  'month.8': ['Aug'],
  'month.9': ['Sep'],
  'month.10': ['Oct'],
  'month.11': ['Nov'],
  'month.12': ['Dec'],
  'date.dm': ['{d} {month}'],
  'date.dmy': ['{d} {month} {y}'],

  // ---------------------------------------------------------------- houses
  'house.1': ['self, body and vitality'],
  'house.2': ['family, speech and savings'],
  'house.3': ['effort, courage and communication'],
  'house.4': ['home, comfort and inner peace'],
  'house.5': ['creativity, romance and children'],
  'house.6': ['daily work, health habits and competition'],
  'house.7': ['partnerships and close relationships'],
  'house.8': ['change, shared resources and hidden matters'],
  'house.9': ['fortune, teachers and higher learning'],
  'house.10': ['career and public standing'],
  'house.11': ['gains, friends and aspirations'],
  'house.12': ['expenses, rest and letting go'],

  // ---------------------------------------------------------------- openers
  'opener.career.1': [
    'Work may ask for extra patience {period}, as the sky leans towards slower progress.',
    'Professional matters tend to move slowly {period}; steady effort counts for more than speed.',
  ],
  'opener.career.2': [
    'Career matters may feel a little uneven {period}.',
    'At work, {period} traditionally favours careful steps over bold moves.',
  ],
  'opener.career.3': [
    'Work looks fairly balanced {period}, with no strong push in either direction.',
    'Professional life tends to stay steady {period}.',
  ],
  'opener.career.4': [
    'Work matters look supportive {period}, and effort tends to be noticed.',
    'The sky traditionally favours progress at work {period}.',
  ],
  'opener.career.5': [
    'Career indications are especially encouraging {period}.',
    '{period} looks like a strong time for work, initiatives and visibility, by traditional reckoning.',
  ],

  'opener.money.1': [
    'Finances may call for extra care {period}.',
    'Money matters tend to need a cautious, practical approach {period}.',
  ],
  'opener.money.2': [
    'Money flow may be a little irregular {period}.',
    'Financially, {period} favours budgeting over big commitments.',
  ],
  'opener.money.3': [
    'Money matters look stable {period}, with modest ups and downs.',
    'Finances tend to stay on an even keel {period}.',
  ],
  'opener.money.4': [
    'Financial indications are favourable {period}.',
    'Money matters tend to improve {period}, according to the transits.',
  ],
  'opener.money.5': [
    'The sky traditionally points to gains and good opportunities with money {period}.',
    'Financial prospects look especially bright {period}.',
  ],

  'opener.love.1': [
    'Relationships may need extra gentleness {period}.',
    'Emotions in close relationships can run a little high {period}; kindness helps.',
  ],
  'opener.love.2': [
    'Love and relationships may feel slightly out of sync {period}.',
    'Close bonds tend to ask for patience and clear words {period}.',
  ],
  'opener.love.3': ['Relationships look calm and steady {period}.', 'Love life tends to stay balanced {period}.'],
  'opener.love.4': [
    'Relationships look warm and supportive {period}.',
    'The transits traditionally favour harmony with loved ones {period}.',
  ],
  'opener.love.5': [
    'Love and companionship look especially sweet {period}.',
    '{period} traditionally favours romance, closeness and good understanding.',
  ],

  'opener.health.1': [
    'Energy may run lower than usual {period}, so rest deserves priority.',
    'Your body may ask for extra care and rest {period}.',
  ],
  'opener.health.2': [
    'Energy levels may fluctuate {period}.',
    'Vitality tends to be a little uneven {period}; pacing yourself helps.',
  ],
  'opener.health.3': ['Energy looks steady {period}.', 'Health and vitality tend to stay balanced {period}.'],
  'opener.health.4': [
    'Energy and vitality look good {period}.',
    'The transits traditionally support strength and stamina {period}.',
  ],
  'opener.health.5': [
    'Vitality looks especially strong {period}.',
    '{period} traditionally brings plenty of energy and resilience.',
  ],

  'opener.mind.1': [
    'The mind may feel restless or heavy {period}; small calming routines help.',
    'Moods may swing more than usual {period}.',
  ],
  'opener.mind.2': [
    'Your mood may be a little sensitive {period}.',
    'Thoughts may scatter easily {period}, so simple plans work best.',
  ],
  'opener.mind.3': ['Mood and focus look balanced {period}.', 'The mind tends to stay steady {period}.'],
  'opener.mind.4': [
    'Mood and clarity look good {period}.',
    'The transits traditionally support a positive, clear mind {period}.',
  ],
  'opener.mind.5': [
    'The mind looks especially bright and optimistic {period}.',
    '{period} traditionally favours clarity, confidence and peace of mind.',
  ],

  // ------------------------------------------------------- transit templates
  'transit.vedic': [
    'With {planet} in the {nth} house from your Moon sign, the area of {theme}, {effect}.',
    '{planet} is moving through the {nth} house from your Moon sign ({theme}); here {effect}.',
    'As {planet} transits the {nth} from your Moon sign, which relates to {theme}, {effect}.',
  ],
  'transit.western': [
    '{planet} in transit {aspectPhrase} your natal {natal}; {effect}.',
    'With {planet} {aspectGerund} your natal {natal}, {effect}.',
  ],
  'transit.solar': [
    'With {planet} in your solar {nth} house of {theme}, {effect}.',
    '{planet} moves through your solar {nth} house ({theme}); here {effect}.',
  ],

  // ------------------------------------------------------- planet effects
  'fx.sun.career.pos': [
    'recognition from seniors and confidence in your role tend to grow',
    'leadership and visibility at work traditionally get a lift',
  ],
  'fx.sun.career.neg': [
    'ego clashes with authority figures are worth avoiding',
    'work may feel demanding, and patience with superiors helps',
  ],
  'fx.sun.money.pos': ['income linked to your own effort or status may improve'],
  'fx.sun.money.neg': ['spending on status or pride is best kept in check'],
  'fx.sun.love.pos': ['warmth and generosity tend to strengthen bonds'],
  'fx.sun.love.neg': ['pride can get in the way, so listening matters more than winning'],
  'fx.sun.health.pos': ['vitality and resilience are traditionally strong'],
  'fx.sun.health.neg': ['heat, fatigue or eye strain may need some attention'],
  'fx.sun.mind.pos': ['self-confidence tends to feel natural'],
  'fx.sun.mind.neg': ['you may feel less recognised than you deserve, which can pass quickly'],

  'fx.moon.career.pos': ['dealings with the public and colleagues tend to go smoothly'],
  'fx.moon.career.neg': ['moods can colour work decisions, so sleep on important choices'],
  'fx.moon.money.pos': ['small gains and comfort-related purchases tend to work out'],
  'fx.moon.money.neg': ['emotional spending is worth watching'],
  'fx.moon.love.pos': ['emotional closeness and understanding tend to come easily'],
  'fx.moon.love.neg': ['sensitivity runs high, so gentle words go a long way'],
  'fx.moon.health.pos': ['rest and nourishment feel restoring'],
  'fx.moon.health.neg': ['irregular sleep or meals may affect your energy'],
  'fx.moon.mind.pos': ['the mind tends to feel content and settled'],
  'fx.moon.mind.neg': ['the mind may feel restless; quiet time helps'],

  'fx.mars.career.pos': [
    'drive and initiative tend to bring results, especially in competition',
    'bold, energetic work traditionally pays off',
  ],
  'fx.mars.career.neg': ['impatience or arguments at work are best avoided'],
  'fx.mars.money.pos': ['effort-driven gains, property or technical work may benefit'],
  'fx.mars.money.neg': ['hasty or impulsive spending may be regretted later'],
  'fx.mars.love.pos': ['passion and protectiveness add energy to relationships'],
  'fx.mars.love.neg': ['tempers can flare quickly; pausing before reacting helps'],
  'fx.mars.health.pos': ['physical energy and stamina tend to be high'],
  'fx.mars.health.neg': ['rushing may lead to strain or small bumps, so move mindfully'],
  'fx.mars.mind.pos': ['courage and decisiveness come more easily'],
  'fx.mars.mind.neg': ['irritability may rise; physical activity can release it'],

  'fx.mercury.career.pos': [
    'communication, analysis and paperwork tend to go well',
    'learning, writing and negotiations are traditionally favoured',
  ],
  'fx.mercury.career.neg': ['double-check messages and details before sending'],
  'fx.mercury.money.pos': ['trade, deals and clever planning may bring gains'],
  'fx.mercury.money.neg': ['read the fine print carefully in financial matters'],
  'fx.mercury.love.pos': ['light, friendly conversations bring people closer'],
  'fx.mercury.love.neg': ['misunderstandings are possible, so say what you mean clearly'],
  'fx.mercury.health.pos': ['nervous energy is well balanced'],
  'fx.mercury.health.neg': ['overthinking may affect sleep or nerves'],
  'fx.mercury.mind.pos': ['the mind tends to be quick and curious'],
  'fx.mercury.mind.neg': ['thoughts may scatter; writing things down helps'],

  'fx.jupiter.career.pos': [
    'guidance from mentors and growth opportunities tend to appear',
    'expansion, good advice and goodwill at work are traditionally indicated',
  ],
  'fx.jupiter.career.neg': ['growth may feel slower than hoped, so build steadily'],
  'fx.jupiter.money.pos': [
    'gains, savings and wise investments are traditionally favoured',
    'financial growth tends to come through good judgement',
  ],
  'fx.jupiter.money.neg': ['over-optimism with money is worth guarding against'],
  'fx.jupiter.love.pos': ['blessings in family life and commitment tend to flow'],
  'fx.jupiter.love.neg': ['expectations in relationships may need to be kept realistic'],
  'fx.jupiter.health.pos': ['overall well-being tends to feel supported'],
  'fx.jupiter.health.neg': ['moderation with rich food and rest is helpful'],
  'fx.jupiter.mind.pos': ['optimism, faith and wisdom come more naturally'],
  'fx.jupiter.mind.neg': ['you may doubt your direction for a while; reflection helps'],

  'fx.venus.career.pos': ['creative work, diplomacy and teamwork tend to shine'],
  'fx.venus.career.neg': ['comfort may tempt you to postpone tasks, so pace yourself'],
  'fx.venus.money.pos': [
    'comforts, gifts and pleasant purchases tend to work out',
    'money linked to art, beauty or partnerships may improve',
  ],
  'fx.venus.money.neg': ['spending on luxuries may run higher than planned'],
  'fx.venus.love.pos': [
    'romance, affection and harmony are traditionally strong',
    'relationships tend to feel sweet and easy',
  ],
  'fx.venus.love.neg': ['small disappointments in love are possible; open hearts help'],
  'fx.venus.health.pos': ['you tend to feel relaxed and well'],
  'fx.venus.health.neg': ['indulgence may affect your energy, so balance treats with care'],
  'fx.venus.mind.pos': ['enjoyment and a sense of beauty lift the mood'],
  'fx.venus.mind.neg': ['you may crave comfort more than usual'],

  'fx.saturn.career.pos': [
    'patient, disciplined work tends to bring lasting results',
    'persistence and responsibility are traditionally rewarded',
  ],
  'fx.saturn.career.neg': [
    'work may feel slow or heavy, and steady effort is the best response',
    'delays are possible, so plan with extra time',
  ],
  'fx.saturn.money.pos': ['long-term savings and careful planning tend to pay off'],
  'fx.saturn.money.neg': ['finances may feel tight, so simple budgeting helps'],
  'fx.saturn.love.pos': ['commitment and loyalty tend to deepen'],
  'fx.saturn.love.neg': ['relationships may feel serious or distant for a while; patience helps'],
  'fx.saturn.health.pos': ['healthy routines are easier to keep'],
  'fx.saturn.health.neg': ['fatigue, joints or teeth may need care, and regular rest helps'],
  'fx.saturn.mind.pos': ['focus and seriousness help you finish what you start'],
  'fx.saturn.mind.neg': ['the mind may feel weighed down; small steps keep you moving'],

  'fx.rahu.career.pos': ['unconventional ideas and foreign or technology links may help'],
  'fx.rahu.career.neg': ['confusion or unclear promises at work are worth checking'],
  'fx.rahu.money.pos': ['unexpected gains are possible'],
  'fx.rahu.money.neg': ['risky or get-rich-quick offers are best avoided'],
  'fx.rahu.love.pos': ['new and unusual connections may form'],
  'fx.rahu.love.neg': ['mixed signals in relationships call for honesty'],
  'fx.rahu.health.pos': ['you tend to have a restless but useful energy'],
  'fx.rahu.health.neg': ['irregular habits may affect your energy'],
  'fx.rahu.mind.pos': ['ambition and curiosity run high'],
  'fx.rahu.mind.neg': ['anxiety or overthinking may rise; grounding routines help'],

  'fx.ketu.career.pos': ['research, technical or behind-the-scenes work tends to go well'],
  'fx.ketu.career.neg': ['you may feel detached from work goals for a while'],
  'fx.ketu.money.pos': ['letting go of what no longer serves you can free resources'],
  'fx.ketu.money.neg': ['avoid neglecting financial details'],
  'fx.ketu.love.pos': ['quiet understanding matters more than words'],
  'fx.ketu.love.neg': ['you may feel distant from others; reaching out helps'],
  'fx.ketu.health.pos': ['simple living and rest feel restoring'],
  'fx.ketu.health.neg': ['small, puzzling complaints are worth getting checked if they persist'],
  'fx.ketu.mind.pos': ['intuition and spiritual interest are traditionally strong'],
  'fx.ketu.mind.neg': ['the mind may feel unfocused; meditation or quiet walks help'],

  'fx.uranus.career.pos': ['fresh ideas and sudden openings may appear'],
  'fx.uranus.career.neg': ['unexpected changes at work call for flexibility'],
  'fx.uranus.money.pos': ['surprising opportunities with money are possible'],
  'fx.uranus.money.neg': ['sudden expenses are possible, so keep a small buffer'],
  'fx.uranus.love.pos': ['exciting, unusual connections may spark'],
  'fx.uranus.love.neg': ['a need for space may stir up relationships'],
  'fx.uranus.health.pos': ['a new routine may energise you'],
  'fx.uranus.health.neg': ['nervous tension may need release'],
  'fx.uranus.mind.pos': ['insight and originality come more easily'],
  'fx.uranus.mind.neg': ['restlessness may make it hard to settle'],

  'fx.neptune.career.pos': ['creative, caring and imaginative work tends to flow'],
  'fx.neptune.career.neg': ['unclear situations at work deserve a careful second look'],
  'fx.neptune.money.pos': ['generosity tends to come back to you'],
  'fx.neptune.money.neg': ['vague financial deals are best clarified first'],
  'fx.neptune.love.pos': ['romance and compassion feel heightened'],
  'fx.neptune.love.neg': ['seeing people as they really are helps avoid disappointment'],
  'fx.neptune.health.pos': ['rest, music and water may feel especially healing'],
  'fx.neptune.health.neg': ['energy may feel low or foggy, so rest helps'],
  'fx.neptune.mind.pos': ['dreams, imagination and spirituality are strong'],
  'fx.neptune.mind.neg': ['confusion is possible; simple routines keep you grounded'],

  'fx.pluto.career.pos': ['deep focus can transform your work situation'],
  'fx.pluto.career.neg': ['power struggles at work are best handled calmly'],
  'fx.pluto.money.pos': ['shared resources and long-term investments may grow'],
  'fx.pluto.money.neg': ['control over shared money may need careful talks'],
  'fx.pluto.love.pos': ['relationships may deepen through honesty'],
  'fx.pluto.love.neg': ['intense feelings may surface; honest talk helps'],
  'fx.pluto.health.pos': ['regenerative habits work well'],
  'fx.pluto.health.neg': ['stress may build up, so make time to recover'],
  'fx.pluto.mind.pos': ['inner strength and determination grow'],
  'fx.pluto.mind.neg': ['old worries may resurface, ready to be released'],

  // ------------------------------------------------------- advice
  'advice.career.low': [
    'Keep commitments small and realistic, and finish one thing at a time.',
    'Focus on preparation rather than big launches.',
  ],
  'advice.career.mid': [
    'Steady, organised effort is the best approach.',
    'Clear plans and good follow-up will serve you well.',
  ],
  'advice.career.high': [
    'It is a good time to share ideas and take sensible initiative.',
    'Use the momentum to move important work forward.',
  ],
  'advice.money.low': [
    'Postpone large purchases if you can, and track daily spending.',
    'Simple budgeting and patience are your best tools.',
  ],
  'advice.money.mid': [
    'Stick to your plan and avoid impulsive decisions.',
    'Review your budget calmly and keep some savings aside.',
  ],
  'advice.money.high': [
    'Thoughtful planning can make the most of good opportunities.',
    'It can be a good time to review savings and long-term goals.',
  ],
  'advice.love.low': [
    'Listen more than you speak, and give people a little space.',
    'Kind words and patience can soften any tension.',
  ],
  'advice.love.mid': ['Small gestures of care keep bonds strong.', 'Making time for loved ones is worthwhile.'],
  'advice.love.high': [
    'Share your feelings openly and enjoy time together.',
    'It is a lovely time to reconnect with the people who matter.',
  ],
  'advice.health.low': [
    'Prioritise sleep, light food and gentle movement.',
    'Rest when you need to, and do not push through tiredness.',
  ],
  'advice.health.mid': [
    'Regular meals, water and movement keep you balanced.',
    'A steady routine supports your energy.',
  ],
  'advice.health.high': [
    'Good energy makes it a fine time for exercise or new healthy habits.',
    'Use your vitality well, while still getting enough rest.',
  ],
  'advice.mind.low': [
    'A few minutes of quiet breathing, prayer or a walk can settle the mind.',
    'Keep plans simple and be gentle with yourself.',
  ],
  'advice.mind.mid': ['Short breaks help you stay clear and calm.', 'Journaling your thoughts can bring clarity.'],
  'advice.mind.high': [
    'Clear thinking makes it a good time for planning and learning.',
    'Enjoy the positive mood and share it with others.',
  ],

  // ------------------------------------------------------- overall
  'overall.1': [
    '{period} traditionally calls for patience and care. Slow down, keep things simple and look after yourself.',
    'The sky suggests a quieter, more careful {periodNoun}. Gentle steps work better than force.',
  ],
  'overall.2': [
    '{period} looks mixed, with a few areas asking for extra care.',
    'Expect a {periodNoun} with some ups and downs; steady habits help.',
  ],
  'overall.3': [
    '{period} looks balanced, neither especially easy nor difficult.',
    'An even {periodNoun} is indicated, with room for steady progress.',
  ],
  'overall.4': [
    '{period} looks supportive overall, with several helpful transits.',
    'The transits point to a positive {periodNoun} with good opportunities.',
  ],
  'overall.5': [
    '{period} looks especially favourable by traditional reckoning.',
    'A bright {periodNoun} is indicated, with strong support from the planets.',
  ],
  'periodNoun.daily': ['day'],
  'periodNoun.weekly': ['week'],
  'periodNoun.monthly': ['month'],
  'periodNoun.yearly': ['year'],

  // ------------------------------------------------------- tara bala
  'tara.name.0': ['Janma'],
  'tara.name.1': ['Sampat'],
  'tara.name.2': ['Vipat'],
  'tara.name.3': ['Kshema'],
  'tara.name.4': ['Pratyari'],
  'tara.name.5': ['Sadhaka'],
  'tara.name.6': ['Naidhana'],
  'tara.name.7': ['Mitra'],
  'tara.name.8': ['Parama Mitra'],
  'tara.text.0': ['Janma tara (the birth star) traditionally asks for rest and reflection rather than new beginnings.'],
  'tara.text.1': ['Sampat tara traditionally supports wealth and prosperity.'],
  'tara.text.2': ['Vipat tara traditionally suggests caution with new ventures.'],
  'tara.text.3': ['Kshema tara traditionally supports well-being and comfort.'],
  'tara.text.4': ['Pratyari tara traditionally suggests avoiding conflicts.'],
  'tara.text.5': ['Sadhaka tara traditionally supports achievement and effort.'],
  'tara.text.6': ['Naidhana tara traditionally advises extra care and a quiet approach.'],
  'tara.text.7': ['Mitra tara traditionally brings friendly support.'],
  'tara.text.8': ['Parama Mitra tara traditionally brings very friendly support.'],

  // ------------------------------------------------------- western aspects
  'aspect.conjunction': ['conjunction'],
  'aspect.sextile': ['sextile'],
  'aspect.square': ['square'],
  'aspect.trine': ['trine'],
  'aspect.opposition': ['opposition'],
  'aspect.phrase.conjunction': ['joins'],
  'aspect.phrase.sextile': ['forms a supportive sextile to'],
  'aspect.phrase.square': ['forms a challenging square to'],
  'aspect.phrase.trine': ['forms a harmonious trine to'],
  'aspect.phrase.opposition': ['opposes'],
  'aspect.gerund.conjunction': ['joining'],
  'aspect.gerund.sextile': ['forming a supportive sextile to'],
  'aspect.gerund.square': ['forming a challenging square to'],
  'aspect.gerund.trine': ['forming a harmonious trine to'],
  'aspect.gerund.opposition': ['opposing'],
  'eclipse.total': ['A total'],
  'eclipse.annular': ['An annular'],
  'eclipse.partial': ['A partial'],
  'eclipse.penumbral': ['A penumbral'],
  'eclipse.hybrid': ['A hybrid'],

  // ------------------------------------------------------- reasons
  'reason.gochara.fav': [
    '{planet} transits {sign}, the {nth} house from your Moon sign {moonSign}. Phaladeepika (ch. 26) lists the {nth} as a favourable transit position for {planet}.',
  ],
  'reason.gochara.unfav': [
    '{planet} transits {sign}, the {nth} house from your Moon sign {moonSign}. Phaladeepika (ch. 26) does not list the {nth} among {planet}\'s favourable transit positions.',
  ],
  'reason.gochara.vedha': [
    '{planet} transits {sign}, the {nth} house from your Moon sign {moonSign}, traditionally favourable, but {other} in the {vnth} forms a vedha (obstruction) that is said to reduce the benefit.',
  ],
  'reason.gochara.asc': [' It is the {nth} house from your Ascendant.'],
  'reason.retro': [' {planet} is retrograde.'],
  'reason.span.most': [' (for most of this period)'],
  'reason.span.part': [' (for part of this period)'],
  'reason.tara': ['The Moon is in {nakshatra}, the {count} nakshatra from your birth star {birth}: {tara}. {text}'],
  'reason.aspect': ['{planet} in transit forms a {aspect} to your natal {natal} (orb {orb}°).'],
  'reason.signaspect': [
    '{planet}, now in {sign}, is in the {nth} sign from your Sun sign {sun} (whole-sign {aspect}).',
  ],
  'reason.signaspect.none': ['{planet}, now in {sign}, is in the {nth} sign from your Sun sign {sun}.'],
  'reason.approx.moon': [
    'Your Moon sign is approximate: the Moon changed sign on your birth date and your birth time is not known.',
  ],
  'reason.approx.nakshatra': ['Your birth star is approximate because your birth time is not known.'],
  'reason.approx.sun': [
    'Your Sun sign is approximate: the Sun changed sign on your birth date and your birth time is not known.',
  ],

  // ------------------------------------------------------- events
  'event.ingress': ['{planet} enters {sign} on {date}.'],
  'event.retro': ['{planet} turns retrograde in {sign} on {date}.'],
  'event.direct': ['{planet} turns direct in {sign} on {date}.'],
  'event.solar': ['{kind} solar eclipse takes place on {date}, in {sign}.'],
  'event.lunar': ['{kind} lunar eclipse takes place on {date}, in {sign}.'],
  'event.moonsign': ['The Moon moves into {sign} at {time}.'],

  // ------------------------------------------------------- why
  'why.vedic': [
    'This reading is calculated from the actual planetary positions {period}, counted from your Moon sign {moonSign} using the classical Gochara (transit) rules of Phaladeepika, including vedha (obstructions){tara}. It describes tendencies traditionally linked to these positions, not certainties, and other traditions may read the same sky differently.',
  ],
  'why.western': [
    'This reading is calculated from the actual planetary positions {period} and the aspects they form to {target}. It describes tendencies traditionally linked to these patterns, not certainties, and other astrologers may weigh them differently.',
  ],
  'why.tara': [' and Tara Bala from your birth star'],
  'why.target.natal': ['the planets in your birth chart'],
  'why.target.sun': ['your Sun sign {sun}'],
  'why.sign': [
    ' This is a general reading for everyone with the {sign} sign; add your birth details for a personal reading.',
  ],
  'why.approx': [' Some of your birth details are approximate, so treat this reading as indicative.'],

  // ------------------------------------------------------- lucky
  'lucky.color.sun': ['Orange'],
  'lucky.color.moon': ['White'],
  'lucky.color.mars': ['Red'],
  'lucky.color.mercury': ['Green'],
  'lucky.color.jupiter': ['Yellow'],
  'lucky.color.venus': ['Light pink'],
  'lucky.color.saturn': ['Dark blue'],
  'lucky.note': ['Traditional associations of {planet}, the ruler of {weekday}. They are customs, not promises.'],
  'lucky.hora': ['Hora of {planet}'],
};
