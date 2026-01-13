import 'package:flutter/material.dart';

class DiseaseDetail {
  final String id;
  final String name;
  final String imagePath;
  final String category;
  final String description;
  final String? epidemiology;
  final List<String>? matchWeather;
  final List<InfoSection> symptoms;
  final List<InfoSection> prevention;
  final List<InfoSection> treatment;

  DiseaseDetail({
    required this.id,
    required this.name,
    required this.imagePath,
    required this.category,
    required this.description,
    this.epidemiology,
    this.matchWeather,
    this.symptoms = const [],
    this.prevention = const [],
    this.treatment = const [],
  });
}

class InfoSection {
  final String title;
  final String description;

  InfoSection({required this.title, required this.description});
}

// Mock Data List
final List<DiseaseDetail> mockDiseaseList = [
  // Rice Blast
  DiseaseDetail(
    id: 'rice_blast',
    name: 'โรคไหม้\n(Rice Blast Disease)',
    imagePath: 'assets/mock/rice_blast.jpg',
    category: 'เชื้อรา',
    description:
        'พบทุกภาคในประเทศไทย ในข้าวนาสวน ทั้งนาปีและนาปรัง และข้าวไร่ สาเหตุเกิดจากเชื้อรา Pyricularia oryzae',
    epidemiology:
        'พบโรคในแปลงที่ต้นข้าวหนาแน่น ทำให้อับลม ถ้าใส่ปุ๋ยไนโตรเจนสูงและมีสภาพแห้งในตอนกลางวันและชื้นจัดในตอนกลางคืน น้ำค้างยาวนานถึงตอนสายราว 9 โมง อากาศค่อนข้างเย็น อุณหภูมิประมาณ 22-25 °C ลมแรงจะช่วยให้โรคแพร่กระจายได้ดี',
    matchWeather: [
      'อุณหภูมิ 22-25 °C (อากาศค่อนข้างเย็น)',
      'ความชื้นสูง (หมอก / น้ำค้างแรง)',
      'ฟ้าปิด / อับลม / ฝนพรำ',
    ],
    symptoms: [
      InfoSection(
        title: 'ระยะกล้า',
        description:
            'ใบมีแผลจุดสีน้ำตาลคล้ายรูปตา ตรงกลางสีเทา ขอบแผลสีน้ำตาลแดง (กว้าง 2-5 มม. ยาว 10-15 มม.) ถ้าอาการรุนแรงกล้าจะแห้งฟุบตาย',
      ),
      InfoSection(
        title: 'ระยะแตกกอ',
        description:
            'แผลใหญ่กว่าระยะกล้า ลุกลามที่ข้อต่อใบและลำต้น ใบมีแผลช้ำสีน้ำตาลดำและมักหลุดจากกาบใบ',
      ),
      InfoSection(
        title: 'ระยะออกรวง (โรคเน่าคอรวง)',
        description:
            'ถ้าเป็นระยะเริ่มออกรวง เมล็ดจะลีบหมด\n\nถ้าเป็นระยะใกล้เก็บเกี่ยว จะเกิดรอยแผลช้ำสีน้ำตาลที่คอรวง ทำให้เปราะหักง่าย รวงร่วงหล่น',
      ),
    ],
    prevention: [
      InfoSection(
        title: 'ใช้พันธุ์ต้านทาน',
        description:
            'ภาคกลาง: สุพรรณบุรี 1, 60\nภาคเหนือ: หอมพิษณุโลก 1\n*ระวังสุพรรณบุรี 1 ในพื้นที่อากาศเย็น*',
      ),
      InfoSection(
        title: 'จัดการแปลงนา',
        description:
            'หว่านเมล็ด 15-20 กก./ไร่ และอย่าใส่ปุ๋ยไนโตรเจนสูงเกินไป (>50 กก./ไร่) จะทำให้โรคลามเร็ว',
      ),
    ],
    treatment: [
      InfoSection(
        title: 'การใช้สารเคมี',
        description:
            'คลุกเมล็ด: ไตรไซคลาโซล, คาซูกาไมซิน\n\nฉีดพ่น: เมื่อพบโรค 5% ของพื้นที่ใบ ให้ฉีดพ่นสารกำจัดเชื้อราตามอัตราที่ระบุ (ไตรไซคลาโซล, คาร์เบนดาซิม)',
      ),
    ],
  ),

  // Brown Spot
  DiseaseDetail(
    id: 'brown_spot',
    name: 'โรคใบจุดสีน้ำตาล\n(Brown Spot Disease)',
    imagePath: 'assets/mock/brown_spot.jpg',
    category: 'เชื้อรา',
    description:
        'พบใน ข้าวนาสวน (นาปีและนาปรัง) และข้าวไร่ ทุกภาคของประเทศไทย\nสาเหตุ: เชื้อรา Bipolaris oryzae',
    epidemiology:
        'เกิดจากสปอร์ของเชื้อราปลิวไปตามลม และติดไปกับเมล็ด การปลูกข้าวแบบต่อเนื่อง ไม่พักดินและขาดการปรับปรุงบำรุงดิน เพิ่มการระบาดของโรค',
    matchWeather: ['ดินขาดความอุดมสมบูรณ์', 'ปลูกข้าวต่อเนื่องไม่พักดิน'],
    symptoms: [
      InfoSection(
        title: 'ลักษณะแผล',
        description:
            'พบมากในระยะแตกกอ จุดสีน้ำตาล รูปกลมหรือรูปไข่ ขอบนอกสุดสีเหลือง (0.5-1 มม.) แผลเต็มที่ขนาด 1-2 x 4-10 มม.',
      ),
      InfoSection(
        title: 'ผลกระทบต่อเมล็ด',
        description:
            'แผลสามารถเกิดบนเมล็ดข้าวเปลือก (โรคเมล็ดด่าง) ทำให้เมล็ดเสื่อมคุณภาพ สีข้าวสารแล้วหักง่าย',
      ),
    ],
    prevention: [
      InfoSection(
        title: 'พันธุ์ต้านทาน',
        description:
            'ภาคกลาง: ปทุมธานี 1\nภาคเหนือ/อีสาน: เหนียวสันป่าตอง, หางยี 71',
      ),
      InfoSection(
        title: 'ปรับปรุงดิน',
        description: 'ไถกลบฟาง ปลูกพืชปุ๋ยสด ใส่ปุ๋ยโปแตสเซียมคลอไรด์ (0-0-60)',
      ),
      InfoSection(
        title: 'จัดการแปลง',
        description: 'กำจัดวัชพืช ดูแลแปลงให้สะอาด',
      ),
    ],
    treatment: [
      InfoSection(
        title: 'การใช้สารเคมี',
        description:
            'คลุกเมล็ด: แมนโคเซ็บ หรือ คาร์เบนดาซิม+แมนโคเซ็บ\n\nฉีดพ่น: เมื่อพบโรค 10% ของใบ หรือระยะตั้งท้อง ให้พ่น คาร์เบนดาซิม, แมนโคเซ็บ, หรือ โพรพิโคนาโซล',
      ),
    ],
  ),

  // Leaf Blight
  DiseaseDetail(
    id: 'leaf_blight',
    name: 'โรคขอบใบแห้ง\n(Leaf Blight Disease)',
    imagePath: 'assets/mock/leaf_blight.jpg',
    category: 'แบคทีเรีย',
    description:
        'พบมากในนาน้ำฝน นาชลประทาน ภาคเหนือ อีสาน และใต้\nสาเหตุ: เชื้อแบคทีเรีย Xanthomonas oryzae pv. oryzae',
    epidemiology:
        'แพร่ไปกับน้ำ ในสภาพความชื้นสูง ฝนตก ลมพัดแรง จะระบาดกว้างขวางรวดเร็ว',
    matchWeather: ['ความชื้นสูง', 'ฝนตกชุก', 'ลมพัดแรง'],
    symptoms: [
      InfoSection(
        title: 'ระยะกล้า',
        description:
            'จุดสีช้ำที่ขอบใบล่าง ต่อมา 7-10 วันกลายเป็นทางสีเหลืองยาว ใบแห้งเร็ว',
      ),
      InfoSection(
        title: 'ระยะแตกกอ (Kresek)',
        description:
            'ใบมีแผลช้ำขอบใบ เปลี่ยนเป็นสีเหลือง มีหยดน้ำสีครีมคล้ายยางสน ถ้าเชื้อรุนแรงต้นข้าวจะเหี่ยวเฉาแห้งตายทั้งต้น (อาการนี้เรียก Kresek)',
      ),
    ],
    prevention: [
      InfoSection(
        title: 'พันธุ์ต้านทาน',
        description: 'สุพรรณบุรี 60, 90, 1, 2, กข7, กข23',
      ),
      InfoSection(
        title: 'การจัดการ',
        description:
            'ไม่ควรใส่ปุ๋ยไนโตรเจนมากในดินอุดมสมบูรณ์ ไม่ระบายน้ำจากแปลงโรคไปแปลงอื่น',
      ),
    ],
    treatment: [
      InfoSection(
        title: 'การใช้สารเคมี',
        description:
            'เมื่อเริ่มพบอาการในพันธุ์อ่อนแอ (เช่น ขาวดอกมะลิ 105) ให้ใช้สาร: ไอโซโพรไทโอเลน, คอปเปอร์ไฮดรอกไซด์, หรือ สเตร็พโตมัยซินซัลเฟต',
      ),
    ],
  ),

  // Leaf Streak
  DiseaseDetail(
    id: 'leaf_streak',
    name: 'โรคใบขีดโปร่งแสง\n(Leaf Streak Disease)',
    imagePath: 'assets/mock/leaf_streak.jpg',
    category: 'แบคทีเรีย',
    description:
        'พบมากในนาน้ำฝน นาชลประทาน ภาคกลาง อีสาน และใต้\nสาเหตุ: เชื้อแบคทีเรีย Xanthomonas oryzae pv. oryzicola',
    epidemiology:
        'ฝนตก ลมพัดแรง ช่วยให้โรคระบาดเร็ว (ถ้าสภาพไม่เหมาะสม ใบใหม่อาจไม่แสดงอาการ)',
    matchWeather: ['ฝนตกชุก', 'ลมพัดแรง'],
    symptoms: [
      InfoSection(
        title: 'ลักษณะแผล',
        description:
            'เป็นขีดช้ำยาวตามเส้นใบ เปลี่ยนเป็นสีเหลือง/ส้ม แสงทะลุผ่านได้ มีหยดน้ำสีเหลืองคล้ายยางสน',
      ),
      InfoSection(
        title: 'พันธุ์อ่อนแอ',
        description: 'แผลขยายจนใบไหม้ถึงกาบใบ',
      ),
    ],
    prevention: [
      InfoSection(
        title: 'การจัดการ',
        description:
            'ไม่ควรใส่ปุ๋ยไนโตรเจนมาก\nไม่ควรปลูกข้าวแน่นเกินไป\nอย่าให้ระดับน้ำในนาสูงเกินควร',
      ),
    ],
    treatment: [],
  ),
];
