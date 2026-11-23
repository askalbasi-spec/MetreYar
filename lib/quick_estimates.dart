import 'package:flutter/material.dart';
import 'core/ads.dart';
import 'core/boq.dart';
import 'core/estimate_engine.dart';
import 'core/numbers.dart';
import 'workspace.dart';

export 'core/numbers.dart' show parseEstimateNumber;

/// Number of tools in the full list (used on the home page).
int get estimateToolCount => _estimates.length;


class _InputSpec {
  const _InputSpec(this.key, this.label, this.unit, {this.initial = ''});
  final String key;
  final String label;
  final String unit;
  final String initial;
}

class _EstimateSpec {
  const _EstimateSpec({
    required this.id,
    required this.title,
    required this.description,
    this.formula,
    this.inputs = const [],
    this.resultUnit = '',
    this.warning,
    this.guide,
  });

  final int id;
  final String title;
  final String description;
  final String? formula;
  final List<_InputSpec> inputs;
  final String resultUnit;
  final String? warning;
  final String? guide;
}

const _estimates = <_EstimateSpec>[
  _EstimateSpec(id: 1, title: 'وزن میلگرد در هر متر', description: 'وزن تقریبی میلگرد از روی قطر و طول کل.', formula: 'قطر² ÷ ۱۶۲ × طول', inputs: [_InputSpec('diameter', 'قطر اسمی', 'میلی‌متر'), _InputSpec('length', 'طول کل', 'متر')], resultUnit: 'کیلوگرم', warning: 'وزن واقعی ممکن است با وزن اسمی و تلرانس کارخانه تفاوت داشته باشد.'),
  _EstimateSpec(id: 2, title: 'سرانه میلگرد بر اساس زیربنا', description: 'تخمین مقدار میلگرد با انتخاب بازه مصرف در هر مترمربع.', formula: 'زیربنا × سرانه انتخابی', inputs: [_InputSpec('area', 'زیربنای کل', 'مترمربع'), _InputSpec('rate', 'سرانه مصرف انتخابی', 'کیلوگرم بر مترمربع', initial: '50')], resultUnit: 'کیلوگرم', warning: 'سرانه‌های ۳۵ تا ۷۰ کیلوگرم بر مترمربع صرفاً بازه‌های اولیه‌اند؛ سیستم سازه، دهانه‌ها، تعداد طبقات و نقشه‌ها تعیین‌کننده‌اند.'),
  _EstimateSpec(id: 3, title: 'سرانه میلگرد بر اساس حجم بتن', description: 'برآورد تناژ میلگرد از حجم بتن و نرخ مصرف انتخابی.', formula: 'حجم بتن × سرانه انتخابی', inputs: [_InputSpec('volume', 'حجم بتن', 'مترمکعب'), _InputSpec('rate', 'سرانه مصرف انتخابی', 'کیلوگرم بر مترمکعب', initial: '100')], resultUnit: 'کیلوگرم', warning: 'بازه ۸۰ تا ۱۲۰ و در پروژه‌های پرتراکم تا حدود ۱۵۰ کیلوگرم بر مترمکعب فقط تخمین اولیه است.'),
  _EstimateSpec(id: 4, title: 'سرانه آهن‌آلات اسکلت فولادی', description: 'تخمین وزن فولاد سازه‌ای بدون میلگرد سقف.', formula: 'زیربنا × سرانه انتخابی', inputs: [_InputSpec('area', 'زیربنای کل', 'مترمربع'), _InputSpec('rate', 'سرانه انتخابی', 'کیلوگرم بر مترمربع', initial: '80')], resultUnit: 'کیلوگرم', warning: 'بازه‌های تقریبی اعلام‌شده ۴۵ تا ۱۲۰ کیلوگرم بر مترمربع‌اند و جایگزین طراحی و فهرست مصالح نیستند.'),
  _EstimateSpec(id: 5, title: 'تعداد دهانه مهاربندی', description: 'راهنمای بررسی اولیه آرایش دهانه‌های مهاربندی.', guide: 'تعداد و محل دهانه‌های مهاربندی را نمی‌توان با یک نسبت سرانگشتی عمومی و بدون اطلاعات پلان، سیستم باربر جانبی، نامنظمی، دریفت و ضوابط لرزه‌ای تعیین کرد. این بخش فعلاً چک‌لیست طراحی اولیه است: پلان محورها، طول و عرض ساختمان، محل بازشوها، نوع مهاربند و مسیر انتقال نیرو باید توسط مهندس محاسب بررسی شود.'),
  _EstimateSpec(id: 6, title: 'طول و جانمایی دیوار برشی', description: 'ملاحظات اولیه جانمایی دیوار برشی.', guide: 'طول و ضخامت دیوار برشی تابع ارتفاع و هندسه ساختمان، بارهای جانبی، مقاومت مصالح، حدود شکل‌پذیری، کنترل دریفت و ضوابط لرزه‌ای است. بدون تحلیل سازه عدد ثابت یا فرمول سرانگشتی قابل اتکا وجود ندارد. این راهنما برای یادآوری کنترل تقارن، پیوستگی تا فونداسیون و پرهیز از پیچش نامطلوب است.'),
  _EstimateSpec(id: 7, title: 'تعداد آجر در هر مترمربع دیوار', description: 'تخمین تعداد آجر با سرانه قابل ویرایش.', formula: 'مساحت دیوار × تعداد آجر در مترمربع', inputs: [_InputSpec('area', 'مساحت خالص دیوار', 'مترمربع'), _InputSpec('rate', 'تعداد آجر در هر مترمربع', 'عدد', initial: '70')], resultUnit: 'عدد آجر', warning: 'مقادیر ۷۰، ۱۳۷ و ۲۱۷ عدد به ابعاد آجر، ضخامت واقعی دیوار، بند ملات و پرت وابسته‌اند. بازشوها را از مساحت کم کنید.'),
  _EstimateSpec(id: 8, title: 'ملات دیوارچینی', description: 'برآورد ملات و اجزای سیمان و ماسه با نسبت اختلاط انتخابی.', formula: 'حجم دیوار × ضریب ملات', inputs: [_InputSpec('wall', 'حجم کل دیوار', 'مترمکعب'), _InputSpec('factor', 'سهم حجمی ملات از دیوار', 'ضریب', initial: '0.12'), _InputSpec('cement', 'سیمان در هر مترمکعب ملات', 'کیلوگرم', initial: '300'), _InputSpec('sand', 'ماسه در هر مترمکعب ملات', 'کیلوگرم', initial: '1800')], resultUnit: 'مترمکعب ملات', warning: 'ضریب یک‌سومِ حجم دیوار که گاهی نقل می‌شود برای همه انواع دیوارچینی قابل تعمیم نیست؛ مقدار واقعی به نوع واحد بنایی و ضخامت بندها وابسته است. خروجی سیمان و ماسه نیز تخمینی است.'),
  _EstimateSpec(id: 9, title: 'ملات مصرفی کف‌سازی', description: 'محاسبه ملات بر اساس مساحت و ضخامت لایه.', formula: 'مساحت × ضخامت', inputs: [_InputSpec('area', 'مساحت کف', 'مترمربع'), _InputSpec('thickness', 'ضخامت ملات', 'سانتی‌متر', initial: '3')], resultUnit: 'مترمکعب ملات', warning: 'عدد ۳۰ لیتر بر مترمربع معادل ضخامت متوسط ۳ سانتی‌متر است؛ ضخامت واقعی زیرسازی را اندازه‌گیری کنید.'),
  _EstimateSpec(id: 10, title: 'ملات و اندود سقف', description: 'محاسبه حجم ملات بر اساس سطح و ضخامت واقعی.', formula: 'مساحت × ضخامت', inputs: [_InputSpec('area', 'مساحت سقف', 'مترمربع'), _InputSpec('thickness', 'ضخامت ملات یا اندود', 'سانتی‌متر')], resultUnit: 'مترمکعب', warning: 'اعداد ۵۰۰ و ۷۷۰ لیتر در هر مترمربع که در متن اولیه آمده‌اند بسیار بزرگ و نیازمند راستی‌آزمایی منبع و واحد هستند؛ به‌صورت پیش‌فرض وارد نشده‌اند. ضخامت واقعی را وارد کنید.'),
  _EstimateSpec(id: 11, title: 'انتخاب اولیه نوع فونداسیون', description: 'راهنمای عوامل مؤثر بر انتخاب پی.', guide: 'انتخاب پی منفرد، نواری، گسترده یا عمیق بر اساس نوع خاک به‌تنهایی ممکن نیست. گزارش مکانیک خاک، ظرفیت باربری مجاز، نشست کل و نسبی، سطح آب زیرزمینی، بار ستون‌ها، همجواری‌ها و محدودیت اجرا لازم است. تصمیم نهایی باید بر پایه گزارش ژئوتکنیک و طراحی مهندس محاسب باشد.'),
  _EstimateSpec(id: 12, title: 'ضریب زلزله (C)', description: 'راهنمای پارامترهای ضریب زلزله و استاندارد ۲۸۰۰.', guide: 'ضریب زلزله تابع ویرایش معتبر استاندارد ۲۸۰۰، پهنه خطر نسبی، نوع زمین، اهمیت ساختمان، سیستم سازه‌ای و دوره تناوب است. چون ویرایش و اصلاحیه‌های معتبر باید کنترل شوند، این نسخه عدد ثابت ارائه نمی‌کند. پیش از استفاده، متن رسمی و آخرین اصلاحیه‌های استاندارد ۲۸۰۰ را بررسی کنید.'),
  _EstimateSpec(id: 13, title: 'حجم بتن ستون یا شمع استوانه‌ای', description: 'محاسبه حجم بتن عضو استوانه‌ای از قطر و ارتفاع.', formula: 'π × قطر² ÷ ۴ × ارتفاع', inputs: [_InputSpec('diameter', 'قطر', 'متر'), _InputSpec('height', 'ارتفاع', 'متر')], resultUnit: 'مترمکعب', warning: 'برای عضو مستطیلی از ابزار «حجم بتن مستطیلی» استفاده کنید. حجم خالص یا ناخالص را متناسب با هدف متره انتخاب کنید.'),
  _EstimateSpec(id: 14, title: 'درز انقطاع ساختمان', description: 'راهنمای کنترل فاصله لرزه‌ای ساختمان‌های مجاور.', guide: 'درز انقطاع تابع ارتفاع، جابجایی جانبی طرح، ضوابط استاندارد ۲۸۰۰ و شرایط ساختمان مجاور است. عبارت «تا ۸ طبقه» به‌تنهایی برای تعیین فاصله کافی نیست. مقدار نهایی را از ضابطه معتبر و محاسبات پروژه استخراج کنید و جزئیات پوشش درز را نیز در نظر بگیرید.'),
  _EstimateSpec(id: 15, title: 'سطح اشغال و قاعده ۲۵ متر و ۴۵ درجه', description: 'راهنمای بررسی اولیه نورگیری و محدودیت‌های حجمی.', guide: 'قاعده موسوم به ۲۵ متر و ۴۵ درجه را نباید قانون یکسان و سراسری تلقی کرد. سطح اشغال، عقب‌نشینی، نورگیری و محدودیت ارتفاع تابع طرح تفصیلی، پهنه، دستور نقشه و ضوابط شهرداری محل است. ملاک اجرا، دستور نقشه و مقررات محلیِ به‌روز است.'),
  _EstimateSpec(id: 16, title: 'تأمین پارکینگ و رمپ', description: 'چک‌لیست اولیه پارکینگ فضاهای مختلف.', guide: 'تعداد پارکینگ موردنیاز، ابعاد جای پارک، عرض مسیر، شیب و پاگرد رمپ به کاربری، مساحت، ضوابط شهرداری و مقررات ملی ساختمان وابسته است. بدون شهر و دستور نقشه عدد ثابت قابل اتکا نیست. پیش از تثبیت پلان، گردش خودرو، شعاع گردش، ارتفاع آزاد و دسترسی افراد کم‌توان را نیز بررسی کنید.'),
  _EstimateSpec(id: 17, title: 'ابعاد سرانگشتی پله و آسانسور', description: 'راهنمای کنترل اولیه ابعاد و دسترسی.', guide: 'ابعاد کف و ارتفاع پله، عرض راه‌پله، پاگرد، تعداد پله، ابعاد چاه و کابین آسانسور تابع تعداد و جمعیت استفاده‌کننده، ارتفاع طبقات، کاربری، الزامات آتش‌نشانی و استانداردهای دسترس‌پذیری و آسانسور است. برای نقشه اجرایی به مقررات و استانداردهای جاری مراجعه شود.'),
  _EstimateSpec(id: 18, title: 'عایق‌کاری حرارتی (مبحث ۱۹)', description: 'راهنمای تخمین اولیه عایق پوسته ساختمان.', guide: 'ضخامت عایق موردنیاز با اقلیم، نوع و لایه‌های دیوار، ضریب هدایت حرارتی، پل‌های حرارتی و ویرایش معتبر مبحث ۱۹ تغییر می‌کند. اعداد ۷٫۵ و ۳ سانتی‌متر یا معادل‌سازی مصالح در متن اولیه، بدون تعیین نوع عایق و مشخصات دیوار، نسخه عمومی و قطعی نیستند. محاسبه نهایی باید بر اساس مقاومت حرارتی کل جداره انجام شود.'),
  _EstimateSpec(id: 19, title: 'مقدار رنگ و گچ‌کاری', description: 'برآورد رنگ و ملات گچ بر اساس سطح و نرخ مصرف.', formula: 'مقدار = مساحت × نرخ مصرف', inputs: [_InputSpec('area', 'مساحت سطح', 'مترمربع'), _InputSpec('rate', 'نرخ مصرف برای هر مترمربع', 'کیلوگرم یا لیتر', initial: '1')], resultUnit: 'واحد ماده', warning: 'نرخ مصرف را از مشخصات محصول، تعداد دست اجرا، زیرکار و پرت واقعی بگیرید. برای رنگ و گچ، نرخ مصرف جداگانه تعریف کنید.'),
  _EstimateSpec(id: 20, title: 'آسفالت و کاشی / سرامیک', description: 'محاسبه حجم آسفالت و تعداد قطعات کف‌پوش.', formula: 'آسفالت: مساحت × ضخامت × چگالی | کاشی: مساحت ÷ مساحت هر قطعه', inputs: [_InputSpec('area', 'مساحت اجرا', 'مترمربع'), _InputSpec('thickness', 'ضخامت آسفالت', 'سانتی‌متر', initial: '5'), _InputSpec('density', 'چگالی آسفالت', 'کیلوگرم بر مترمکعب', initial: '2300'), _InputSpec('tileArea', 'مساحت هر کاشی/سرامیک', 'مترمربع', initial: '0.36'), _InputSpec('waste', 'درصد پرت کاشی', 'درصد', initial: '10')], resultUnit: 'کیلوگرم آسفالت و تعداد قطعه', warning: 'برای آسفالت، چگالی را از طرح اختلاط/مشخصات پیمان بگیرید. تعداد کاشی با گرد کردن به بالا و افزودن پرت محاسبه می‌شود.'),

  _EstimateSpec(id:21,title:'حجم به فرغون و میکسر',description:'تخمین تعداد بار فرغون و سهم ظرفیت میکسر.',formula:'حجم × ۱۰۰۰ ÷ ظرفیت',inputs:[_InputSpec('volume','حجم','مترمکعب'),_InputSpec('wheel','ظرفیت فرغون','لیتر',initial:'90'),_InputSpec('mixer','ظرفیت مفید میکسر','لیتر',initial:'350')],resultUnit:'بار'),
  _EstimateSpec(id:22,title:'خاک‌برداری با تورم خاک',description:'حجم درجا، حجم سست‌شده و سرویس حمل.',formula:'طول × عرض × عمق × ضریب تورم',inputs:[_InputSpec('length','طول','متر'),_InputSpec('width','عرض','متر'),_InputSpec('depth','عمق متوسط','متر'),_InputSpec('factor','ضریب تورم','ضریب',initial:'1.25'),_InputSpec('truck','ظرفیت کامیون','مترمکعب',initial:'10')],resultUnit:'مترمکعب'),
  _EstimateSpec(id:23,title:'سرانه کل بتن سازه',description:'حجم بتن کل از روی زیربنا و سرانه مصرف.',formula:'زیربنا × سرانه بتن',inputs:[_InputSpec('area','زیربنای کل','مترمربع'),_InputSpec('rate','سرانه بتن','مترمکعب بر مترمربع',initial:'0.40')],resultUnit:'مترمکعب بتن',warning:'بازه ۰٫۳۵ تا ۰٫۴۵ صرفاً تخمین اولیه ساختمان متعارف است.'),
  _EstimateSpec(id:24,title:'مصالح سنگی بتن',description:'تخمین شن، ماسه و وزن کل مصالح سنگی.',formula:'حجم بتن × ضرایب مصرف',inputs:[_InputSpec('volume','حجم بتن','مترمکعب'),_InputSpec('total','مصالح سنگی کل','کیلوگرم بر مترمکعب',initial:'2200'),_InputSpec('gravel','شن','مترمکعب بر مترمکعب بتن',initial:'0.80'),_InputSpec('sand','ماسه','مترمکعب بر مترمکعب بتن',initial:'0.45')],resultUnit:'کیلوگرم و مترمکعب'),
  _EstimateSpec(id:25,title:'سرانه میلگرد قاب خمشی',description:'برآورد میلگرد سازه بتنی بر اساس سرانه.',formula:'زیربنا × سرانه میلگرد',inputs:[_InputSpec('area','زیربنای کل','مترمربع'),_InputSpec('rate','سرانه میلگرد','کیلوگرم بر مترمربع',initial:'55')],resultUnit:'کیلوگرم',warning:'بازه ۴۵ تا ۷۰ کیلوگرم فقط تخمین اولیه است؛ لیستوفر ملاک سفارش است.'),
  _EstimateSpec(id:27,title:'ماسه ملات فرش کف',description:'تخمین ماسه بر اساس حجم ملات.',formula:'حجم ملات × سرانه ماسه',inputs:[_InputSpec('volume','حجم ملات','مترمکعب'),_InputSpec('rate','ماسه','کیلوگرم بر مترمکعب',initial:'1670')],resultUnit:'کیلوگرم ماسه'),
  _EstimateSpec(id:28,title:'لوله گرمایش از کف',description:'تخمین طول لوله موردنیاز سطح تحت پوشش.',formula:'مساحت × طول لوله در مترمربع',inputs:[_InputSpec('area','مساحت تحت پوشش','مترمربع'),_InputSpec('rate','طول لوله','متر بر مترمربع',initial:'3')],resultUnit:'متر لوله',warning:'فاصله لوله‌ها و طول مجاز مدار باید در طراحی کنترل شود.'),
  _EstimateSpec(id:29,title:'تیرچه سقف تیرچه‌بلوک',description:'تخمین مجموع طول تیرچه‌ها از مساحت سقف.',formula:'مساحت × ضریب طول تیرچه',inputs:[_InputSpec('area','مساحت سقف','مترمربع'),_InputSpec('rate','ضریب طول','متر بر مترمربع',initial:'1.5')],resultUnit:'متر طول تیرچه'),
  _EstimateSpec(id:30,title:'بلوک یا یونولیت سقف',description:'تخمین تعداد بلوک سقفی.',formula:'مساحت × تعداد در مترمربع',inputs:[_InputSpec('area','مساحت سقف','مترمربع'),_InputSpec('rate','تعداد در مترمربع','عدد',initial:'0.68')],resultUnit:'عدد بلوک'),
  _EstimateSpec(id:31,title:'بتن سقف تیرچه‌بلوک',description:'تخمین بتن مصرفی سقف سبک.',formula:'مساحت × مصرف بتن',inputs:[_InputSpec('area','مساحت سقف','مترمربع'),_InputSpec('rate','مصرف بتن','مترمکعب بر مترمربع',initial:'0.095')],resultUnit:'مترمکعب بتن'),
  _EstimateSpec(id:32,title:'ورق و بتن سقف عرشه فولادی',description:'محاسبه ورق با پرت و بتن با ضخامت مؤثر.',formula:'ورق=مساحت×(۱+پرت)؛ بتن=مساحت×(ضخامت−نصف گوه)',inputs:[_InputSpec('area','مساحت سقف','مترمربع'),_InputSpec('waste','پرت ورق','درصد',initial:'7'),_InputSpec('slab','ضخامت دال','متر',initial:'0.12'),_InputSpec('deck','ارتفاع گوه عرشه','متر',initial:'0.075')],resultUnit:'مترمربع ورق و مترمکعب بتن'),
  _EstimateSpec(id:33,title:'سقف دال مجوف یوبوت/کوبیاکس',description:'تخمین تعداد قالب و بتن با ضخامت معادل.',formula:'قالب=مساحت÷شبکه؛ بتن=مساحت×ضخامت معادل',inputs:[_InputSpec('area','مساحت سقف','مترمربع'),_InputSpec('module','مساحت شبکه هر قالب','مترمربع',initial:'0.25'),_InputSpec('waste','پرت قالب','درصد',initial:'4'),_InputSpec('thickness','ضخامت معادل بتن','متر',initial:'0.18')],resultUnit:'عدد قالب و مترمکعب بتن',warning:'ضخامت معادل و چیدمان قالب باید از نقشه سیستم استخراج شود.'),
  _EstimateSpec(id:35,title:'سیمان و ماسه ملات ۱ به ۶',description:'تخمین اجزای ملات دیوارچینی.',formula:'حجم ملات × سرانه مصالح',inputs:[_InputSpec('volume','حجم ملات','مترمکعب'),_InputSpec('cement','سیمان','کیلوگرم بر مترمکعب',initial:'300'),_InputSpec('sand','ماسه','کیلوگرم بر مترمکعب',initial:'1800')],resultUnit:'کیلوگرم'),
  _EstimateSpec(id:36,title:'آجر بر اساس حجم دیوار',description:'تخمین تعداد آجر در حجم دیوار.',formula:'حجم دیوار × تعداد آجر در مترمکعب',inputs:[_InputSpec('volume','حجم دیوار','مترمکعب'),_InputSpec('rate','تعداد آجر','عدد بر مترمکعب',initial:'610')],resultUnit:'عدد آجر'),
  _EstimateSpec(id:37,title:'بلوک سیمانی یا سفالی تیغه',description:'تعداد بلوک با کسر بازشو و افزودن پرت.',formula:'(مساحت−بازشو)÷مساحت بلوک×(۱+پرت)',inputs:[_InputSpec('area','مساحت دیوار','مترمربع'),_InputSpec('openings','مساحت بازشو','مترمربع',initial:'0'),_InputSpec('block','مساحت نمای بلوک','مترمربع',initial:'0.08'),_InputSpec('waste','پرت','درصد',initial:'6')],resultUnit:'عدد بلوک'),
  _EstimateSpec(id:40,title:'مصالح خشک اندودکاری',description:'تخمین مصالح خشک بر اساس حجم اندود.',formula:'حجم اندود × سرانه مصالح خشک',inputs:[_InputSpec('volume','حجم اندود','مترمکعب'),_InputSpec('rate','مصالح خشک','کیلوگرم بر مترمکعب',initial:'1850')],resultUnit:'کیلوگرم مصالح'),
  _EstimateSpec(id:41,title:'پوشش گچ و خاک',description:'تعداد کیسه ۴۰ کیلویی بر اساس سطح و پرت.',formula:'مساحت÷پوشش هر کیسه×(۱+پرت)',inputs:[_InputSpec('area','سطح','مترمربع'),_InputSpec('coverage','پوشش هر کیسه','مترمربع',initial:'2.8'),_InputSpec('waste','پرت','درصد',initial:'5')],resultUnit:'کیسه ۴۰ کیلویی'),
  _EstimateSpec(id:42,title:'پوشش گچ سفیدکاری',description:'تعداد کیسه گچ سفید ۴۰ کیلویی.',formula:'مساحت÷پوشش هر کیسه×(۱+پرت)',inputs:[_InputSpec('area','سطح','مترمربع'),_InputSpec('coverage','پوشش هر کیسه','مترمربع',initial:'11'),_InputSpec('waste','پرت','درصد',initial:'5')],resultUnit:'کیسه ۴۰ کیلویی'),
  _EstimateSpec(id:43,title:'کناف و سقف کاذب',description:'تخمین ورق، پیچ و شاخص طول سازه فرعی.',formula:'ورق=سطح×(۱+پرت)؛ پیچ=سطح×تعداد؛ پروفیل تقریبی=سطح×۱۰۰÷فاصله',inputs:[_InputSpec('area','سطح','مترمربع'),_InputSpec('waste','پرت ورق','درصد',initial:'10'),_InputSpec('screws','پیچ در مترمربع','عدد',initial:'28'),_InputSpec('spacing','فاصله سازه فرعی','سانتی‌متر',initial:'50')],resultUnit:'مترمربع ورق، عدد پیچ و متر طول تقریبی',warning:'متره پروفیل واقعی به نوع سیستم و نقشه زیرسازی وابسته است.'),
  _EstimateSpec(id:44,title:'رنگ روغنی دو دست',description:'مقدار رنگ با پوشش هر کیلو در هر دست و پرت.',formula:'مساحت×دست÷پوشش×(۱+پرت)',inputs:[_InputSpec('area','مساحت','مترمربع'),_InputSpec('coverage','پوشش هر کیلو در یک دست','مترمربع',initial:'5'),_InputSpec('coats','تعداد دست','عدد',initial:'2'),_InputSpec('waste','پرت','درصد',initial:'15')],resultUnit:'کیلوگرم رنگ'),
  _EstimateSpec(id:45,title:'رنگ پلاستیک و آکریلیک',description:'مقدار رنگ با لحاظ مصرف بیشتر زیرکار جاذب.',formula:'مساحت×دست÷پوشش×(۱+افزایش مصرف)',inputs:[_InputSpec('area','مساحت','مترمربع'),_InputSpec('coverage','پوشش هر کیلو در یک دست','مترمربع',initial:'7'),_InputSpec('coats','تعداد دست','عدد',initial:'2'),_InputSpec('extra','افزایش مصرف','درصد',initial:'15')],resultUnit:'کیلوگرم رنگ'),
  _EstimateSpec(id:46,title:'آجر نمای پلاک و ملات بندکشی',description:'تخمین کارتن آجر ال و کیسه ملات بندکشی.',formula:'کارتن=مساحت÷پوشش کارتن؛ کیسه=مساحت÷پوشش کیسه',inputs:[_InputSpec('area','مساحت نما','مترمربع'),_InputSpec('carton','پوشش هر کارتن ال','مترمربع',initial:'5'),_InputSpec('mortar','پوشش هر کیسه ۵۰ کیلویی','مترمربع',initial:'40')],resultUnit:'کارتن و کیسه'),
  _EstimateSpec(id:47,title:'پرت کاشی، سرامیک و سنگ',description:'محاسبه مساحت سفارش با درصد پرت انتخابی.',formula:'مساحت خالص×(۱+پرت)',inputs:[_InputSpec('area','مساحت خالص','مترمربع'),_InputSpec('waste','پرت','درصد',initial:'7')],resultUnit:'مترمربع سفارش'),
  _EstimateSpec(id:48,title:'ظرفیت گرمایشی و پره رادیاتور',description:'تخمین بار گرمایشی و تعداد پره.',formula:'توان=مساحت×وات بر مترمربع؛ پره=توان÷توان هر پره',inputs:[_InputSpec('area','مساحت مفید','مترمربع'),_InputSpec('rate','بار گرمایشی','وات بر مترمربع',initial:'155'),_InputSpec('fin','توان هر پره','وات',initial:'150')],resultUnit:'وات و تعداد پره'),
  _EstimateSpec(id:49,title:'لوله‌کشی آب و فاضلاب',description:'تخمین طول لوله آب سرد و گرم و لوله فاضلاب، باران و هواکش.',formula:'زیربنا × سرانه هر گروه لوله',inputs:[_InputSpec('area','زیربنای کل','مترمربع'),_InputSpec('waterRate','سرانه آب سرد و گرم','متر بر مترمربع',initial:'0.55'),_InputSpec('drainRate','سرانه فاضلاب و هواکش','متر بر مترمربع',initial:'0.65')],resultUnit:'متر لوله',warning:'این سرانه‌ها فقط برای تخمین اولیه‌اند؛ تعداد سرویس‌ها، رایزرها و نقشه تأسیسات ملاک متره است.'),
  _EstimateSpec(id:50,title:'سیم‌کشی و تجهیزات برق',description:'تخمین طول سیم و تعداد کلید و پریز و تابلو.',formula:'زیربنا × سرانه سیم',inputs:[_InputSpec('area','زیربنا','مترمربع'),_InputSpec('rate','سرانه سیم','متر بر مترمربع',initial:'5'),_InputSpec('points','تعداد کلید و پریز','عدد',initial:'30')],resultUnit:'متر سیم و عدد تجهیزات',warning:'طول واقعی به تعداد مدارها، رشته‌ها، مسیرها و نقشه برق وابسته است.'),
  _EstimateSpec(id:51,title:'حجم بتن مستطیلی',description:'محاسبه حجم بتن عضو مستطیلی از طول، عرض و ارتفاع.',formula:'طول × عرض × ارتفاع',inputs:[_InputSpec('length','طول','متر'),_InputSpec('width','عرض','متر'),_InputSpec('height','ارتفاع','متر')],resultUnit:'مترمکعب بتن'),
  _EstimateSpec(id:53,title:'مساحت مستطیل',description:'محاسبه مساحت سطح مستطیلی.',formula:'طول × عرض',inputs:[_InputSpec('length','طول','متر'),_InputSpec('width','عرض','متر')],resultUnit:'مترمربع'),
]; 

String _categoryForEstimate(int id) {
  if (<int>{13, 21, 23, 24, 31, 32, 33, 51}.contains(id)) return 'بتن‌ریزی';
  if (<int>{1, 2, 3, 4, 5, 6, 7, 8, 11, 12, 14, 15, 16, 17, 22, 25, 29, 30, 34, 35, 36, 37, 52, 53}.contains(id)) return 'سفت‌کاری';
  if (<int>{9, 10, 18, 19, 20, 26, 27, 40, 41, 42, 43, 44, 45, 46, 47}.contains(id)) return 'نازک‌کاری';
  if (<int>{28, 38, 39, 48, 49}.contains(id)) return 'تأسیسات مکانیکی';
  return 'تأسیسات برقی';
}

Widget quickEstimatePage(int id) {
  final spec = _estimates.firstWhere((item) => item.id == id);
  return _EstimateDetailPage(spec: spec);
}

class QuickEstimatesPage extends StatelessWidget {
  const QuickEstimatesPage({super.key, this.initialTabIndex = 0});

  final int initialTabIndex;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: initialTabIndex.clamp(0, 2).toInt(),
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('ابزارهای متره و برآورد'),
          bottom: TabBar(
            isScrollable: true,
            indicatorColor: Theme.of(context).colorScheme.primary,
            indicatorWeight: 3,
            labelColor: Theme.of(context).colorScheme.primary,
            unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
            labelStyle: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
            unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
            tabs: [
              Tab(text: 'بتن و سفت‌کاری'),
              Tab(text: 'نازک‌کاری'),
              Tab(text: 'تأسیسات'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _EstimateTabGroup(categories: ['بتن‌ریزی', 'سفت‌کاری']),
            _EstimateTabGroup(categories: ['نازک‌کاری']),
            _EstimateTabGroup(categories: ['تأسیسات مکانیکی', 'تأسیسات برقی']),
          ],
        ),
      ),
    );
  }
}

class _EstimateTabGroup extends StatelessWidget {
  const _EstimateTabGroup({required this.categories});
  final List<String> categories;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 28),
      children: [
        for (final category in categories) ...[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(13),
              child: Row(children: [
                Container(width: 4, height: 22, decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, borderRadius: BorderRadius.circular(4))),
                const SizedBox(width: 10),
                Text(category, style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w800, fontSize: 15)),
              ]),
            ),
          ),
          for (final item in _estimates.where((e) => _categoryForEstimate(e.id) == category && e.inputs.isNotEmpty))
            Card(
              margin: const EdgeInsets.only(bottom: 9),
              child: ListTile(
                leading: CircleAvatar(
                  radius: 21,
                  backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: .15),
                  child: Text('${item.id}', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
                ),
                title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                subtitle: Text(
                  item.inputs.isEmpty ? 'راهنمای مهندسی — بدون محاسبه عددی' : item.description,
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
                trailing: Icon(Icons.arrow_back_ios_new_rounded, color: Theme.of(context).colorScheme.primary, size: 15),
                onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
                  builder: (_) => _EstimateDetailPage(spec: item),
                )),
              ),
            ),
          if (_estimates.any((e) => _categoryForEstimate(e.id) == category && e.inputs.isEmpty))
            Card(
              margin: const EdgeInsets.only(bottom: 9),
              child: ExpansionTile(
                key: PageStorageKey('guides-$category'),
                leading: Icon(Icons.menu_book_outlined, color: Theme.of(context).colorScheme.primary),
                title: const Text('راهنمای مهندسی (بدون محاسبه عددی)', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                children: [
                  for (final item in _estimates.where((e) => _categoryForEstimate(e.id) == category && e.inputs.isEmpty))
                    ListTile(
                      title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                      subtitle: Text(item.description),
                      trailing: const Icon(Icons.arrow_back_ios_new_rounded, size: 14),
                      onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
                        builder: (_) => _EstimateDetailPage(spec: item),
                      )),
                    ),
                ],
              ),
            ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _EstimateDetailPage extends StatefulWidget {
  const _EstimateDetailPage({required this.spec});
  final _EstimateSpec spec;

  @override
  State<_EstimateDetailPage> createState() => _EstimateDetailPageState();
}

class _EstimateDetailPageState extends State<_EstimateDetailPage> {
  final Map<String, TextEditingController> _controllers = {};
  String? _result;
  String? _error;

  @override
  void initState() {
    super.initState();
    for (final field in widget.spec.inputs) {
      _controllers[field.key] = TextEditingController(text: field.initial);
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  double _value(String key, {bool allowZero = false}) {
    final controller = _controllers[key];
    final field = widget.spec.inputs.where((item) => item.key == key);
    final label = field.isEmpty ? key : field.first.label;
    if (controller == null) {
      throw FormatException('فیلد «$label» در این محاسبه تعریف نشده است.');
    }
    return parseEstimateNumber(controller.text, label: label, allowZero: allowZero);
  }

  Future<void> _addToBoq() async {
    final q = parseResultQuantity(_result ?? '');
    if (q == null) return;
    final project = await WorkspaceStore.activeProject();
    await BoqStore.upsert(BoqItem(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: widget.spec.title,
      unit: q.unit,
      qty: q.qty,
      unitPrice: 0,
      projectId: project?.id,
    ));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('به صورت‌مقادیر افزوده شد. قیمت واحد را آنجا وارد کنید.')));
  }

  Future<void> _calculate() async {
    try {
      final result = computeEstimate(widget.spec.id, _value, resultUnit: widget.spec.resultUnit);
      setState(() { _result = result; _error = null; });
      final entered = widget.spec.inputs.map((field) => '${field.label}: ${_controllers[field.key]?.text ?? ''} ${field.unit}').join('، ');
      final activeProject = await WorkspaceStore.activeProject();
      await WorkspaceStore.addHistory(
        title: widget.spec.title,
        formula: widget.spec.formula ?? 'راهنمای مهندسی',
        result: result,
        inputs: entered,
        projectId: activeProject?.id,
        projectName: activeProject?.name,
      );
    } on Object catch (e) {
      setState(() { _result = null; _error = e is FormatException ? e.message.toString() : 'ورودی‌ها معتبر نیستند.'; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final spec = widget.spec;
    return Scaffold(
      appBar: AppBar(title: Text(spec.title)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(spec.description, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, height: 1.7)),
          if (spec.formula != null) ...[
            const SizedBox(height: 12),
            Text('فرمول: ${spec.formula}', style: TextStyle(color: Theme.of(context).colorScheme.primary, height: 1.8)),
          ],
          if (spec.inputs.isNotEmpty) ...[
            const SizedBox(height: 18),
            for (final field in spec.inputs)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: TextField(
                  controller: _controllers[field.key],
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(labelText: field.label, suffixText: field.unit),
                ),
              ),
            FilledButton.icon(
              onPressed: _calculate,
              icon: const Icon(Icons.calculate_outlined),
              label: const Text('محاسبه'),
            ),
            if (_result != null) ...[
              const SizedBox(height: 18),
              Card(child: Padding(
                padding: const EdgeInsets.all(16),
                child: SelectableText(_result!, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, height: 1.8)),
              )),
              if (parseResultQuantity(_result!) != null) ...[
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  key: const Key('add-to-boq'),
                  onPressed: _addToBoq,
                  icon: const Icon(Icons.playlist_add),
                  label: const Text('افزودن به صورت‌مقادیر'),
                ),
              ],
            ],
            const AdSlot(),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: const TextStyle(color: Colors.redAccent)),
            ],
          ] else ...[
            const SizedBox(height: 18),
            Card(child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text('راهنمای کنترل اولیه', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
            )),
            const SizedBox(height: 8),
            Text(spec.guide ?? '', style: const TextStyle(height: 1.9)),
          ],
          if (spec.warning != null) ...[
            const SizedBox(height: 18),
            Card(
              color: const Color(0xFF332B20),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Icon(Icons.info_outline, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 10),
                  Expanded(child: Text(spec.warning!, style: const TextStyle(height: 1.7))),
                ]),
              ),
            ),
          ],
          const SizedBox(height: 18),
          Text('این ابزار برای برآورد اولیه و کنترل کارگاهی است و جایگزین نقشه‌ها، مشخصات فنی، گزارش ژئوتکنیک یا محاسبات مهندسی و ضوابط لازم‌الاجرا نیست.', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12, height: 1.8)),
        ],
      ),
    );
  }
}
