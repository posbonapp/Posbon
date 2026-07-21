import 'package:flutter/material.dart';

/// Справочник иконок для дома.
/// Ключ хранится в базе, значок берётся отсюда.
const kIcons = <String, IconData>{
  // ===== САНТЕХНИКА =====
  'shower': Icons.shower,
  'faucet': Icons.water_drop,
  'toilet': Icons.wc,
  'sink': Icons.countertops,
  'bathtub': Icons.bathtub_outlined,
  'pipe': Icons.plumbing,
  'boiler': Icons.hot_tub,
  'water_meter': Icons.water,
  'drain': Icons.waves,

  // ===== БЫТОВАЯ ТЕХНИКА =====
  'washer': Icons.local_laundry_service,
  'dryer': Icons.dry_cleaning,
  'fridge': Icons.kitchen,
  'stove': Icons.microwave,
  'oven': Icons.bakery_dining,
  'dishwasher': Icons.wash,
  'hood': Icons.air,
  'tv': Icons.tv,
  'ac': Icons.ac_unit,
  'fan': Icons.toys,
  'heater': Icons.thermostat,
  'radiator': Icons.heat_pump,
  'water_heater': Icons.water_damage,

  // ===== ЭЛЕКТРИКА =====
  'bulb': Icons.lightbulb_outline,
  'lamp': Icons.light,
  'ceiling_light': Icons.wb_incandescent_outlined,
  'chandelier': Icons.blur_circular,
  'battery': Icons.battery_full,
  'battery_small': Icons.battery_std,
  'cable': Icons.cable,
  'wire': Icons.electrical_services,
  'socket': Icons.power,
  'switch': Icons.toggle_on,
  'panel': Icons.dashboard_customize_outlined,
  'meter': Icons.speed,
  'fuse': Icons.flash_on,

  // ===== ПОЛ, СТЕНЫ, ПОТОЛОК =====
  'floor': Icons.grid_on,
  'tile': Icons.dashboard_outlined,
  'carpet': Icons.texture,
  'wall': Icons.wallpaper,
  'ceiling': Icons.roofing,
  'paint': Icons.format_paint,
  'wallpaper': Icons.photo_library_outlined,

  // ===== ДВЕРИ, ОКНА, ЗАМКИ =====
  'door': Icons.door_front_door,
  'door_back': Icons.door_back_door,
  'window': Icons.window,
  'lock': Icons.lock_outline,
  'key': Icons.key,
  'handle': Icons.pan_tool_outlined,
  'intercom': Icons.doorbell,
  'peephole': Icons.remove_red_eye_outlined,

  // ===== ОБЩЕЕ ИМУЩЕСТВО =====
  'elevator': Icons.elevator,
  'stairs': Icons.stairs,
  'parking': Icons.local_parking,
  'gate': Icons.fence,
  'barrier': Icons.horizontal_rule,
  'garage': Icons.garage,
  'trash': Icons.delete_outline,
  'camera': Icons.videocam_outlined,
  'mailbox': Icons.markunread_mailbox_outlined,
  'playground': Icons.child_friendly,
  'garden': Icons.park_outlined,
  'roof': Icons.house_siding,
  'basement': Icons.foundation,

  // ===== ВЕНТИЛЯЦИЯ =====
  'vent': Icons.hvac,
  'duct': Icons.wind_power,
  'filter': Icons.filter_alt_outlined,

  // ===== БЕЗОПАСНОСТЬ =====
  'smoke': Icons.smoke_free,
  'alarm': Icons.notifications_active_outlined,
  'extinguisher': Icons.fire_extinguisher,
  'sensor': Icons.sensors,

  // ===== ИНСТРУМЕНТЫ И РАСХОДНИКИ =====
  'tool': Icons.build_outlined,
  'screw': Icons.hardware,
  'drill': Icons.construction,
  'glue': Icons.opacity,
  'silicone': Icons.colorize,
  'tape': Icons.linear_scale,
  'clean': Icons.cleaning_services,
  'brush': Icons.brush,
  'mop': Icons.sanitizer,
  'gloves': Icons.back_hand_outlined,
  'ladder': Icons.stacked_line_chart,

  // ===== ПРОЧЕЕ =====
  'furniture': Icons.chair_outlined,
  'mirror': Icons.crop_portrait,
  'shelf': Icons.shelves,
  'other': Icons.inventory_2_outlined,
};

IconData iconFor(String? key) => kIcons[key] ?? Icons.inventory_2_outlined;

/// Автоподбор иконки по названию товара (RU/EN/FR)
String guessIcon(String name) {
  final n = name.toLowerCase().trim();
  const rules = <List<String>>[
    // ── САНТЕХНИКА ──
    ['shower', 'душ', 'сушилк', 'dryer', 'douche', 'séchoir'],
    ['faucet', 'кран', 'смесит', 'faucet', 'tap', 'robinet', 'mitigeur'],
    ['toilet', 'унитаз', 'туалет', 'бачок', 'toilet', 'toilette', 'wc'],
    ['sink', 'раковин', 'мойка', 'умывальник', 'sink', 'lavabo', 'évier'],
    ['bathtub', 'ванна', 'ванную', 'bath', 'baignoire'],
    ['pipe', 'труба', 'трубы', 'канализац', 'pipe', 'tuyau', 'tuyaux'],
    ['boiler', 'бойлер', 'водонагрев', 'boiler', 'chauffe-eau'],
    ['water_meter', 'счётчик воды', 'счетчик воды', 'water meter', 'compteur eau'],
    ['drain', 'слив', 'сток', 'drain', 'siphon'],

    // ── БЫТОВАЯ ТЕХНИКА ──
    ['washer', 'стирал', 'washer', 'washing', 'lave-linge', 'machine à laver'],
    ['fridge', 'холодильник', 'морозильник', 'fridge', 'frigo', 'réfrigérateur'],
    ['dishwasher', 'посудомо', 'dishwasher', 'lave-vaisselle'],
    ['stove', 'плита', 'варочн', 'stove', 'cuisinière', 'plaque'],
    ['oven', 'духовк', 'печь', 'oven', 'four'],
    ['hood', 'вытяжк', 'hood', 'hotte'],
    ['tv', 'телевизор', 'тв', 'tv', 'télé', 'téléviseur'],
    ['ac', 'кондицион', 'сплит', 'ac', 'climatiseur', 'clim'],
    ['fan', 'вентилятор', 'fan', 'ventilateur'],
    ['heater', 'обогрев', 'тепловентил', 'heater', 'chauffage', 'radiateur élec'],
    ['radiator', 'батаре', 'радиатор', 'radiator', 'radiateur'],
    ['water_heater', 'водонагрев', 'water heater'],

    // ── ЭЛЕКТРИКА ──
    ['bulb', 'лампочк', 'лампа', 'светодиод', 'bulb', 'lamp', 'ampoule'],
    ['ceiling_light', 'светильник', 'люстра', 'плафон', 'ceiling', 'lustre', 'plafonnier'],
    ['battery', 'батарейк', 'аккумулятор', 'battery', 'pile', 'batterie'],
    ['cable', 'кабель', 'провод', 'проводк', 'cable', 'câble', 'fil'],
    ['socket', 'розетка', 'socket', 'outlet', 'prise'],
    ['switch', 'выключател', 'switch', 'interrupteur'],
    ['panel', 'щиток', 'щит', 'panel', 'tableau élec'],
    ['meter', 'счётчик', 'счетчик', 'meter', 'compteur'],
    ['fuse', 'предохранит', 'автомат', 'пробк', 'fuse', 'fusible', 'disjoncteur'],

    // ── ПОЛ, СТЕНЫ, ПОТОЛОК ──
    ['floor', 'пол ', 'ламинат', 'паркет', 'линолеум', 'floor', 'plancher', 'sol'],
    ['tile', 'плитка', 'кафель', 'керамогранит', 'tile', 'carrelage', 'carreau'],
    ['carpet', 'ковёр', 'ковер', 'палас', 'carpet', 'tapis', 'moquette'],
    ['wall', 'стена', 'стены', 'wall', 'mur'],
    ['ceiling', 'потолок', 'ceiling', 'plafond'],
    ['paint', 'краск', 'эмаль', 'грунтовк', 'paint', 'peinture'],
    ['wallpaper', 'обои', 'wallpaper', 'papier peint'],

    // ── ДВЕРИ, ОКНА, ЗАМКИ ──
    ['door', 'дверь', 'двери', 'дверн', 'door', 'porte'],
    ['window', 'окно', 'окна', 'стеклопакет', 'window', 'fenêtre', 'vitre'],
    ['lock', 'замок', 'защёлк', 'засов', 'lock', 'serrure', 'verrou'],
    ['key', 'ключ', 'key', 'clé', 'clef'],
    ['handle', 'ручка', 'handle', 'poignée'],
    ['intercom', 'домофон', 'звонок дверн', 'intercom', 'interphone'],
    ['peephole', 'глазок', 'peephole', 'judas'],

    // ── ОБЩЕЕ ИМУЩЕСТВО ──
    ['elevator', 'лифт', 'elevator', 'lift', 'ascenseur'],
    ['stairs', 'лестниц', 'ступен', 'stairs', 'escalier'],
    ['parking', 'парковк', 'паркинг', 'parking'],
    ['gate', 'ворота', 'калитка', 'gate', 'portail'],
    ['barrier', 'шлагбаум', 'barrier', 'barrière'],
    ['garage', 'гараж', 'garage'],
    ['trash', 'мусор', 'пакет', 'урна', 'бак', 'trash', 'poubelle', 'déchet'],
    ['camera', 'камера', 'видеонаблюд', 'cctv', 'camera', 'caméra'],
    ['mailbox', 'почтов', 'ящик', 'mailbox', 'boîte aux lettres'],
    ['playground', 'площадка', 'детск', 'качел', 'playground', 'aire de jeux'],
    ['garden', 'газон', 'клумба', 'сад', 'garden', 'jardin', 'pelouse'],

    // ── ВЕНТИЛЯЦИЯ, ОТОПЛЕНИЕ ──
    ['vent', 'вентиляц', 'решётк вент', 'vent', 'ventilation', 'aération'],
    ['duct', 'воздуховод', 'duct', 'conduit'],
    ['filter', 'фильтр', 'filter', 'filtre'],

    // ── БЕЗОПАСНОСТЬ ──
    ['smoke', 'дым', 'пожарн', 'извещател', 'smoke', 'fumée', 'incendie'],
    ['alarm', 'сигнализац', 'сирена', 'alarm', 'alarme'],
    ['extinguisher', 'огнетушит', 'extinguisher', 'extincteur'],
    ['sensor', 'датчик', 'sensor', 'capteur', 'détecteur'],

    // ── ИНСТРУМЕНТЫ, РАСХОДНИКИ ──
    ['tool', 'инструмент', 'отвёртк', 'ключ гаечн', 'молоток', 'плоскогубц', 'tool', 'outil', 'clé'],
    ['screw', 'шуруп', 'саморез', 'винт', 'болт', 'гайк', 'дюбел', 'screw', 'vis', 'boulon', 'cheville'],
    ['drill', 'сверло', 'дрель', 'бур', 'перфоратор', 'drill', 'perceuse', 'foret'],
    ['glue', 'клей', 'glue', 'colle'],
    ['silicone', 'силикон', 'герметик', 'silicone', 'mastic'],
    ['tape', 'скотч', 'изолент', 'лента', 'tape', 'ruban', 'scotch'],
    ['clean', 'чистящ', 'моющ', 'средство', 'clean', 'nettoyant', 'détergent'],
    ['brush', 'кисть', 'кисточк', 'щётка', 'валик', 'brush', 'pinceau', 'brosse'],
    ['mop', 'швабра', 'тряпк', 'mop', 'serpillière', 'balai'],
    ['gloves', 'перчатк', 'gloves', 'gants'],
    ['ladder', 'лестниц стрем', 'стремянк', 'ladder', 'échelle'],

    // ── МЕБЕЛЬ, ПРОЧЕЕ ──
    ['furniture', 'мебель', 'стул', 'стол', 'шкаф', 'полк', 'furniture', 'meuble', 'chaise'],
    ['mirror', 'зеркал', 'mirror', 'miroir'],
    ['shelf', 'полка', 'стеллаж', 'shelf', 'étagère'],
  ];

  for (final rule in rules) {
    final icon = rule.first;
    for (final kw in rule.skip(1)) {
      if (n.contains(kw)) return icon;
    }
  }
  return 'other';
}