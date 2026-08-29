import 'package:flutter/material.dart';

class MyCustomFormScreen extends StatefulWidget {
  const MyCustomFormScreen({Key? key}) : super(key: key);

  @override
  State<MyCustomFormScreen> createState() => _MyCustomFormScreenState();
}

class _MyCustomFormScreenState extends State<MyCustomFormScreen> {
  // 1. إنشاء مفتاح فريد للتحكم في حالة النموذج والـ Validation
  final _formKey = GlobalKey<FormState>();

  // 2. استخدام Controller للتحكم في الحقول التي تحتاج قراءة مباشرة أو تهيئة مسبقة
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    // تنظيف الـ Controllers عند إغلاق الشاشة لتفادي تسريب الذاكرة
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  // دالة لإظهار الـ AlertDialog للتأكيد
  void _showConfirmationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // يمنع إغلاق الديالوج عند الضغط خارجه
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('تأكيد إرسال البيانات'),
          content: Text('هل أنت متأكد من صحة البيانات المدخلة للاسم: ${_nameController.text}؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(), // إغلاق الديالوج فقط
              child: const Text('تعديل'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // إغلاق الديالوج
                _showSuccessSnackBar(); // إظهار رسالة النجاح
              },
              child: const Text('تأكيد وإرسال'),
            ),
          ],
        );
      },
    );
  }

  // دالة لإظهار الـ SnackBar بعد التأكيد
  void _showSuccessSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('تم استقبال بياناتك وتحديث الحساب بنجاح!'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'حسنًا',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  // دالة لإظهار الـ BottomSheet لعرض شروط الاستخدام
  void _showTermsBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min, // يجعل الارتفاع متناسباً مع المحتوى
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'شروط وسياسة الاستخدام',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                '1. نحن نحافظ على خصوصية بياناتك بالكامل.\n'
                '2. لن يتم مشاركة البريد الإلكتروني مع أي جهة خارجية.\n'
                '3. يمكنك تعديل بياناتك في أي وقت من الإعدادات.',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('موافق وإغلاق'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة النماذج والتنبيهات'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey, // ربط الـ Form بالمفتاح الذكي
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // حقل إدخال الاسم
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'الاسم الكامل',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'الرجاء إدخال الاسم';
                  }
                  if (value.trim().length < 3) {
                    return 'يجب أن يكون الاسم 3 أحرف أو أكثر';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // حقل إدخال البريد الإلكتروني
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'البريد الإلكتروني',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'الرجاء إدخال البريد الإلكتروني';
                  }
                  // تحقق بسيط من صيغة الإيميل
                  if (!value.contains('@') || !value.contains('.')) {
                    return 'الرجاء إدخال بريد إلكتروني صحيح';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // زر التحقق والارسال (يفعل الـ Dialog والـ SnackBar)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () {
                  // تشغيل دالة الـ Validation لجميع الحقول المرتبطة بالـ Form
                  if (_formKey.currentState!.validate()) {
                    // إذا نجح الفحص، ننتقل لخطوة التأكيد عبر Dialog
                    _showConfirmationDialog();
                  }
                },
                child: const Text('حفظ البيانات', style: TextStyle(fontSize: 16)),
              ),
              const SizedBox(height: 12),

              // زر مخصص لاستعراض الـ BottomSheet
              TextButton.icon(
                onPressed: _showTermsBottomSheet,
                icon: const Icon(Icons.info_outline),
                label: const Text('قراءة شروط الاستخدام والأمان'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
