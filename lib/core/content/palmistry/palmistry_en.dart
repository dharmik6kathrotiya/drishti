import 'palmistry_content.dart';

// Traditional palmistry meanings, written in our own words. Palmistry is a
// symbolic tradition; nothing here is a medical or factual claim.
const palmistryEn = PalmistryTexts(
  intro:
      'Palmistry (Hasta Samudrika Shastra in India, chiromancy in the West) reads the shape and '
      'lines of the hand as symbols of temperament. Look at your hand in good light and answer '
      'a few questions; your answers are combined into a traditional reading.',
  noScanNote:
      'On Android, Drishti can find your hand in a photo and suggest the main lines, using image '
      'processing on your phone. It is not always right: you check every suggestion and can redraw '
      'any line. The photo stays on your phone and is never uploaded.',
  whichHand:
      'Traditionally, the dominant hand (the one you write with) shows how you live now, and the '
      'other hand shows inborn tendencies.',
  closing:
      'Palmistry is a traditional, symbolic practice. Lines change over a lifetime and do not '
      'decide your future, your health or the length of your life. Use this as reflection, '
      'not prediction.',
  questions: [
    PalmQuestion(
      id: 'shape',
      area: PalmArea.hand,
      title: 'Hand shape',
      help: 'Compare the palm (from wrist to the base of the fingers) with the length of your fingers.',
      options: [
        PalmOption(
          'Square palm, short fingers (Earth)',
          'Practical, steady and dependable. You tend to like routine, tangible results and working with your hands.',
        ),
        PalmOption(
          'Square palm, long fingers (Air)',
          'Curious, sociable and analytical. Communication and ideas tend to energise you.',
        ),
        PalmOption(
          'Long palm, short fingers (Fire)',
          'Energetic, spontaneous and enthusiastic. You tend to act quickly and inspire others.',
        ),
        PalmOption(
          'Long palm, long fingers (Water)',
          'Sensitive, imaginative and intuitive. Creative work and deep connections tend to matter most.',
        ),
      ],
    ),
    PalmQuestion(
      id: 'heart',
      area: PalmArea.heartLine,
      title: 'Heart line',
      help: 'The upper horizontal line, starting under the little finger and running towards the index finger.',
      options: [
        PalmOption(
          'Ends between the index and middle fingers',
          'Traditionally a sign of balance between head and heart in emotional life.',
        ),
        PalmOption(
          'Curves up to end under the index finger',
          'Traditionally linked with warmth, idealism and high standards in close bonds.',
        ),
        PalmOption(
          'Ends under the middle finger',
          'Traditionally linked with a practical, self-reliant approach to feelings.',
        ),
        PalmOption(
          'Runs straight across the palm',
          'Traditionally linked with a calm, steady and thoughtful emotional nature.',
        ),
        PalmOption(
          'Wavy or chained',
          'Traditionally linked with sensitivity and changeable feelings; emotional self-care may help.',
        ),
      ],
    ),
    PalmQuestion(
      id: 'head',
      area: PalmArea.headLine,
      title: 'Head line',
      help: 'The middle horizontal line, starting between the thumb and index finger.',
      options: [
        PalmOption('Long and straight', 'Traditionally linked with clear, logical and focused thinking.'),
        PalmOption('Slopes down towards the wrist', 'Traditionally linked with imagination and creative thinking.'),
        PalmOption('Short', 'Traditionally linked with quick, practical decisions.'),
        PalmOption(
          'Starts separate from the life line',
          'Traditionally linked with independence and a love of adventure.',
        ),
        PalmOption(
          'Forked at the end',
          'Often called the "writer\'s fork": traditionally linked with seeing many sides of an idea.',
        ),
      ],
    ),
    PalmQuestion(
      id: 'life',
      area: PalmArea.lifeLine,
      title: 'Life line',
      help: 'The curved line around the base of the thumb. Its length is NOT the length of life.',
      options: [
        PalmOption(
          'Wide curve far into the palm',
          'Traditionally linked with vitality, enthusiasm and a love of activity.',
        ),
        PalmOption('Close to the thumb', 'Traditionally linked with a reserved nature that values home and calm.'),
        PalmOption('Long, deep and clear', 'Traditionally linked with steadiness and resilience.'),
        PalmOption(
          'Broken or with overlapping sections',
          'Traditionally read as times of change in lifestyle or direction, not as harm.',
        ),
        PalmOption('Has a parallel "sister" line', 'Traditionally read as support, protection or strong family bonds.'),
      ],
    ),
    PalmQuestion(
      id: 'fate',
      area: PalmArea.fateLine,
      title: 'Fate line',
      help: 'A vertical line running up the centre of the palm towards the middle finger. Many hands do not have one.',
      options: [
        PalmOption(
          'Deep and clear from the wrist',
          'Traditionally linked with a strong sense of direction from early life.',
        ),
        PalmOption(
          'Starts from the life line',
          'Traditionally linked with a path shaped by personal effort and family.',
        ),
        PalmOption(
          'Starts from the outer edge of the palm',
          'Traditionally linked with a path shaped by other people and public life.',
        ),
        PalmOption('Starts in the middle of the palm', 'Traditionally linked with finding direction later in life.'),
        PalmOption(
          'Faint or absent',
          'Traditionally linked with a flexible, self-made path rather than one fixed course.',
        ),
      ],
    ),
    PalmQuestion(
      id: 'mounts',
      area: PalmArea.mounts,
      title: 'Most prominent mount',
      help: 'The fleshy pads under the fingers and at the base of the palm. Which looks fullest?',
      options: [
        PalmOption(
          'Under the index finger (Jupiter)',
          'Traditionally linked with ambition, leadership and a wish to guide others.',
        ),
        PalmOption(
          'Under the middle finger (Saturn)',
          'Traditionally linked with responsibility, patience and a serious outlook.',
        ),
        PalmOption(
          'Under the ring finger (Sun / Apollo)',
          'Traditionally linked with creativity, warmth and appreciation of beauty.',
        ),
        PalmOption(
          'Under the little finger (Mercury)',
          'Traditionally linked with communication, wit and business sense.',
        ),
        PalmOption('Base of the thumb (Venus)', 'Traditionally linked with affection, warmth and enjoyment of life.'),
        PalmOption(
          'Outer base of the palm (Moon)',
          'Traditionally linked with imagination, intuition and love of travel.',
        ),
      ],
    ),
    PalmQuestion(
      id: 'fingers',
      area: PalmArea.fingers,
      title: 'Index and ring fingers',
      help: 'Compare the length of the index (first) finger with the ring (third) finger.',
      options: [
        PalmOption('Index finger longer', 'Traditionally linked with confidence and a wish to lead.'),
        PalmOption('Ring finger longer', 'Traditionally linked with creativity and willingness to take risks.'),
        PalmOption('About the same length', 'Traditionally linked with a balanced, even temperament.'),
      ],
    ),
    PalmQuestion(
      id: 'thumb',
      area: PalmArea.thumb,
      title: 'Thumb',
      help: 'Gently press your thumb back. Is it flexible or firm?',
      options: [
        PalmOption('Flexible, bends back easily', 'Traditionally linked with adaptability and generosity.'),
        PalmOption('Firm, hardly bends', 'Traditionally linked with determination and steadiness.'),
        PalmOption('Long thumb', 'Traditionally linked with willpower and good reasoning.'),
        PalmOption('Short thumb', 'Traditionally linked with being guided more by feeling than by planning.'),
      ],
    ),
  ],
);
