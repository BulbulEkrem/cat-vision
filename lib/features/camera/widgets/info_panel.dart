import 'package:flutter/material.dart';

/// Bottom sheet with educational cards about cat vision.
class InfoPanel extends StatelessWidget {
  const InfoPanel({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const InfoPanel(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF1A1A1A),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Title
              const Padding(
                padding: EdgeInsets.all(20),
                child: Row(
                  children: [
                    Icon(Icons.pets, color: Color(0xFF7CFC00), size: 28),
                    SizedBox(width: 12),
                    Text(
                      'Kediler Dünyayı Nasıl Görür?',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // Cards
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                  children: const [
                    _InfoCard(
                      icon: Icons.palette,
                      iconColor: Color(0xFF5B9BD5),
                      title: 'Dikromatik Görüş',
                      description:
                          'Kediler sadece iki tip renk reseptörüne (koni hücre) sahiptir — '
                          'mavi-mor ve sarı-yeşil. Kırmızı ve yeşili net ayırt edemezler. '
                          'Dünyaları daha çok mavi ve sarı tonlarından oluşur, '
                          'tıpkı kırmızı-yeşil renk körlüğüne benzer şekilde.',
                    ),
                    _InfoCard(
                      icon: Icons.nightlight_round,
                      iconColor: Color(0xFFFFD700),
                      title: 'Gece Görüşü (Tapetum Lucidum)',
                      description:
                          'Kedilerin gözlerinin arkasında "tapetum lucidum" adlı yansıtıcı '
                          'bir tabaka bulunur. Bu tabaka, ışığı retinaya geri yansıtarak '
                          'kedilerin insanlardan 6-8 kat daha az ışıkta görmesini sağlar. '
                          'Karanlıkta gözlerinin parlamasının nedeni de budur!',
                    ),
                    _InfoCard(
                      icon: Icons.panorama_horizontal,
                      iconColor: Color(0xFF90EE90),
                      title: 'Geniş Görüş Açısı',
                      description:
                          'Kedilerin görüş açısı yaklaşık 200°\'dir (insanlar ~180°). '
                          'Bu geniş periferal görüş, avcı olarak avlarını ve potansiyel '
                          'tehlikeleri daha iyi algılamalarını sağlar. Ancak periferal '
                          'alandaki keskinlik merkeze göre daha düşüktür.',
                    ),
                    _InfoCard(
                      icon: Icons.speed,
                      iconColor: Color(0xFFFF6B6B),
                      title: 'Hareket Algılama',
                      description:
                          'Kediler hareketi insanlardan çok daha iyi algılar. '
                          'Retinalarındaki çubuk hücrelerin yoğunluğu sayesinde, '
                          'en küçük hareketi bile fark edebilirler. Kedilerin lazer '
                          'noktasını çılgınca takip etmesinin sırrı budur! '
                          'Ancak sabit nesnelere odaklanmada insanlar daha iyidir.',
                    ),
                    _InfoCard(
                      icon: Icons.visibility,
                      iconColor: Color(0xFFDDA0DD),
                      title: 'Keskinlik (Görme Netliği)',
                      description:
                          'Kedilerin görme keskinliği yaklaşık 20/100–20/200 arasındadır '
                          '(insanlarda 20/20). Yani bir insanın 60 metreden net gördüğü '
                          'bir nesneyi, kedi ancak 6 metreden görebilir. Bu yüzden '
                          'kediler için dünya biraz daha bulanıktır.',
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
