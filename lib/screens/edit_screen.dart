import 'package:flutter/material.dart';
import 'package:easy_video_editor/easy_video_editor.dart';
import 'package:provider/provider.dart';
import 'package:video_downloud_app/providers/video_editor_provider.dart';
import 'package:video_downloud_app/utils/app_colors.dart';
import 'package:video_downloud_app/widgets/custom_app_bar.dart';

enum EditType { speed, rotate, crop, compress, flip, multiple }

class EditScreen extends StatefulWidget {
  final String videoPath;
  final EditType editType;

  const EditScreen({
    super.key,
    required this.videoPath,
    required this.editType,
  });

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  double _speed = 1.0;
  RotationDegree _rotation = RotationDegree.degree90;
  VideoAspectRatio _aspectRatio = VideoAspectRatio.ratio16x9;
  VideoResolution _resolution = VideoResolution.p720;
  FlipDirection _flipDirection = FlipDirection.horizontal;

  bool _trimEnabled = false;
  double _startTime = 0;
  double _endTime = 100;
  bool _removeAudio = false;
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          CustomAppBar(title: _getTitle(), isBack: true),
          Expanded(
            child: Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildEditForm(),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: _isProcessing ? null : _applyEdit,
                          icon: const Icon(Icons.check_circle),
                          label: Text(
                            _isProcessing
                                ? 'جاري المعالجة...'
                                : 'تطبيق التغييرات',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                if (_isProcessing)
                  Container(
                    child: Center(
                      child: Card(
                        margin: const EdgeInsets.all(32),
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const CircularProgressIndicator(),
                              const SizedBox(height: 20),
                              const Text(
                                'جاري معالجة الفيديو...',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                'قد يستغرق هذا بضع دقائق',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getTitle() {
    switch (widget.editType) {
      case EditType.speed:
        return 'تغيير السرعة';
      case EditType.rotate:
        return 'تدوير الفيديو';
      case EditType.crop:
        return 'اقتصاص الفيديو';
      case EditType.compress:
        return 'ضغط الفيديو';
      case EditType.flip:
        return 'قلب الفيديو';
      case EditType.multiple:
        return 'فلاتر متعددة';
    }
  }

  Widget _buildEditForm() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: _buildFormContent(),
      ),
    );
  }

  Widget _buildFormContent() {
    switch (widget.editType) {
      case EditType.speed:
        return _buildSpeedForm();
      case EditType.rotate:
        return _buildRotateForm();
      case EditType.crop:
        return _buildCropForm();
      case EditType.compress:
        return _buildCompressForm();
      case EditType.flip:
        return _buildFlipForm();
      case EditType.multiple:
        return _buildMultipleForm();
    }
  }

  Widget _buildSpeedForm() {
    return Column(
      children: [
        const Icon(Icons.speed, size: 64, color: AppColors.accent),
        const SizedBox(height: 20),
        Text(
          'السرعة الحالية: ${_speed.toStringAsFixed(1)}x',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 30),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.accent,
            inactiveTrackColor: AppColors.accent.withOpacity(0.3),
            thumbColor: AppColors.accent,
            overlayColor: AppColors.accent.withOpacity(0.2),
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
          ),
          child: Slider(
            value: _speed,
            min: 0.25,
            max: 4.0,
            divisions: 15,
            label: '${_speed.toStringAsFixed(1)}x',
            onChanged: (value) {
              setState(() {
                _speed = value;
              });
            },
          ),
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          alignment: WrapAlignment.center,
          children: [
            _buildSpeedButton('بطيء جداً', 0.25),
            _buildSpeedButton('بطيء', 0.5),
            _buildSpeedButton('عادي', 1.0),
            _buildSpeedButton('سريع', 2.0),
            _buildSpeedButton('سريع جداً', 4.0),
          ],
        ),
      ],
    );
  }

  Widget _buildSpeedButton(String text, double speed) {
    final isSelected = (_speed - speed).abs() < 0.01;
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _speed = speed;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? AppColors.accent : Colors.white,
        foregroundColor: isSelected ? Colors.white : AppColors.accent,
        elevation: isSelected ? 4 : 1,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: AppColors.primary, width: isSelected ? 2 : 1),
        ),
      ),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildRotateForm() {
    return Column(
      children: [
        const Icon(Icons.rotate_right, size: 64, color: AppColors.accent),
        const SizedBox(height: 20),
        const Text(
          'اختر زاوية التدوير',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 30),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildRotationButton(
              '90°',
              RotationDegree.degree90,
              Icons.rotate_90_degrees_ccw,
            ),
            _buildRotationButton('180°', RotationDegree.degree180, Icons.flip),
            _buildRotationButton(
              '270°',
              RotationDegree.degree270,
              Icons.rotate_90_degrees_cw,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRotationButton(
    String text,
    RotationDegree degree,
    IconData icon,
  ) {
    final isSelected = _rotation == degree;
    return Card(
      elevation: isSelected ? 8 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? AppColors.primary : Colors.grey.shade300,
          width: isSelected ? 3 : 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            _rotation = degree;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 100,
          height: 100,
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 40,
                color: isSelected ? AppColors.accent : Colors.grey,
              ),
              const SizedBox(height: 8),
              Text(
                text,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isSelected ? AppColors.accent : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCropForm() {
    final aspectRatios = [
      {
        'name': '1:1',
        'ratio': VideoAspectRatio.ratio1x1,
        'icon': Icons.crop_square,
      },
      {
        'name': '4:3',
        'ratio': VideoAspectRatio.ratio4x3,
        'icon': Icons.crop_5_4,
      },
      {
        'name': '16:9',
        'ratio': VideoAspectRatio.ratio16x9,
        'icon': Icons.crop_16_9,
      },
      {
        'name': '9:16',
        'ratio': VideoAspectRatio.ratio9x16,
        'icon': Icons.crop_portrait,
      },
    ];

    return Column(
      children: [
        const Icon(Icons.crop, size: 64, color: AppColors.accent),
        const SizedBox(height: 20),
        const Text(
          'اختر نسبة الاقتصاص',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 30),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.2,
          ),
          itemCount: aspectRatios.length,
          itemBuilder: (context, index) {
            final item = aspectRatios[index];
            final isSelected = _aspectRatio == item['ratio'];
            return Card(
              elevation: isSelected ? 8 : 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: isSelected ? AppColors.primary : Colors.grey.shade300,
                  width: isSelected ? 3 : 1,
                ),
              ),
              child: InkWell(
                onTap: () {
                  setState(() {
                    _aspectRatio = item['ratio'] as VideoAspectRatio;
                  });
                },
                borderRadius: BorderRadius.circular(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      item['icon'] as IconData,
                      size: 48,
                      color: isSelected ? AppColors.accent : Colors.grey,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item['name'] as String,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? AppColors.accent : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildCompressForm() {
    final resolutions = [
      {'name': '360p', 'res': VideoResolution.p360, 'desc': 'صغير'},
      {'name': '480p', 'res': VideoResolution.p480, 'desc': 'متوسط'},
      {'name': '720p (HD)', 'res': VideoResolution.p720, 'desc': 'جودة عالية'},
      {
        'name': '1080p (Full HD)',
        'res': VideoResolution.p1080,
        'desc': 'جودة عالية جداً',
      },
      {'name': '4K', 'res': VideoResolution.p2160, 'desc': 'أعلى جودة'},
    ];

    return Column(
      children: [
        const Icon(Icons.compress, size: 64, color: AppColors.accent),
        const SizedBox(height: 20),
        const Text(
          'اختر دقة الضغط',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 30),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: resolutions.length,
          itemBuilder: (context, index) {
            final item = resolutions[index];
            final isSelected = _resolution == item['res'];
            return Card(
              elevation: isSelected ? 4 : 1,
              margin: const EdgeInsets.only(bottom: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: isSelected ? AppColors.primary : Colors.grey.shade300,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: ListTile(
                onTap: () {
                  setState(() {
                    _resolution = item['res'] as VideoResolution;
                  });
                },
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.accent : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.high_quality,
                    color: isSelected ? Colors.white : Colors.grey,
                  ),
                ),
                title: Text(
                  item['name'] as String,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isSelected ? AppColors.accent : Colors.black,
                  ),
                ),
                subtitle: Text(item['desc'] as String),
                trailing: isSelected
                    ? const Icon(Icons.check_circle, color: AppColors.accent)
                    : null,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildFlipForm() {
    return Column(
      children: [
        const Icon(Icons.flip, size: 64, color: Colors.blue),
        const SizedBox(height: 20),
        const Text(
          'اختر اتجاه القلب',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 30),
        Row(
          children: [
            Expanded(
              child: _buildFlipCard(
                'أفقي',
                Icons.flip,
                FlipDirection.horizontal,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildFlipCard('رأسي', Icons.flip, FlipDirection.vertical),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFlipCard(String title, IconData icon, FlipDirection direction) {
    final isSelected = _flipDirection == direction;
    return Card(
      elevation: isSelected ? 8 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? Colors.blue : Colors.grey.shade300,
          width: isSelected ? 3 : 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            _flipDirection = direction;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Transform.rotate(
                angle: direction == FlipDirection.vertical ? 1.5708 : 0,
                child: Icon(
                  icon,
                  size: 60,
                  color: isSelected ? Colors.blue : Colors.grey,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.blue : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMultipleForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'خيارات متقدمة',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),

        Card(
          child: SwitchListTile(
            title: const Text(
              'قص الفيديو',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: const Text('تحديد جزء من الفيديو'),
            value: _trimEnabled,
            activeColor: AppColors.primary,
            onChanged: (value) {
              setState(() {
                _trimEnabled = value;
              });
            },
          ),
        ),

        if (_trimEnabled) ...[
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('البداية: ${_startTime.toInt()} ثانية'),
                  Slider(
                    value: _startTime,
                    min: 0,
                    max: 100,
                    activeColor: AppColors.accent,
                    onChanged: (value) {
                      setState(() {
                        _startTime = value;
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  Text('النهاية: ${_endTime.toInt()} ثانية'),
                  Slider(
                    value: _endTime,
                    min: 0,
                    max: 100,
                    activeColor: AppColors.accent,
                    onChanged: (value) {
                      setState(() {
                        _endTime = value;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
        ],

        const SizedBox(height: 10),
        Card(
          child: SwitchListTile(
            title: const Text(
              'إزالة الصوت',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: const Text('حذف الصوت من الفيديو'),
            value: _removeAudio,
            activeColor: AppColors.primary,
            onChanged: (value) {
              setState(() {
                _removeAudio = value;
              });
            },
          ),
        ),

        const SizedBox(height: 20),
        const Text(
          'تغيير السرعة:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  'السرعة: ${_speed.toStringAsFixed(1)}x',
                  style: const TextStyle(fontSize: 16),
                ),
                Slider(
                  value: _speed,
                  min: 0.25,
                  max: 4.0,
                  activeColor: AppColors.accent,
                  onChanged: (value) {
                    setState(() {
                      _speed = value;
                    });
                  },
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),
        const Text(
          'نسبة الاقتصاص:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        _buildCropForm(),

        const SizedBox(height: 20),
        const Text('دقة الضغط:', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        _buildCompressForm(),
      ],
    );
  }

  Future<void> _applyEdit() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      final provider = context.read<VideoEditorProvider>();
      String? result;

      switch (widget.editType) {
        case EditType.speed:
          result = await provider.changeSpeed(_speed);
          break;
        case EditType.rotate:
          result = await provider.rotateVideo(_rotation);
          break;
        case EditType.crop:
          result = await provider.cropVideo(_aspectRatio);
          break;
        case EditType.compress:
          result = await provider.compressVideo(_resolution);
          break;
        case EditType.flip:
          result = await provider.flipVideo(_flipDirection);
          break;
        case EditType.multiple:
          final operations = <String, dynamic>{};

          if (_trimEnabled) {
            operations['trim'] = {
              'start': _startTime.toInt(),
              'end': _endTime.toInt(),
            };
          }

          if (_speed != 1.0) {
            operations['speed'] = _speed;
          }

          if (_removeAudio) {
            operations['removeAudio'] = true;
          }

          if (_aspectRatio != VideoAspectRatio.ratio16x9) {
            operations['crop'] = _aspectRatio;
          }

          if (_resolution != VideoResolution.p720) {
            operations['compress'] = _resolution;
          }

          result = await provider.applyMultipleOperations(operations);
          break;
      }

      if (result == null) {
        throw Exception(
          provider.errorMessage ?? 'تعذر إنشاء الفيديو أو حفظه في المعرض',
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 10),
                Text('تم تطبيق التغييرات بنجاح'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 10),
                Expanded(child: Text('حدث خطأ: $e')),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }
}
