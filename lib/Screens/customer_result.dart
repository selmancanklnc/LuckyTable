import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucky_table/Screens/customer.dart';
import 'package:lucky_table/Screens/customer_scan.dart';
import 'package:lucky_table/Screens/intro_page.dart';
import 'package:lucky_table/Screens/profile.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:ui' as ui;
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:video_player/video_player.dart';

class CustomerResultPage extends StatefulWidget {
  const CustomerResultPage({
    super.key,
    required this.customerResult,
  });

  final String customerResult;

  @override
  CustomerResultPageState createState() =>
      CustomerResultPageState(customerResult);
}

class CustomerResultPageState extends State<CustomerResultPage>
    with SingleTickerProviderStateMixin {
  late String customerResult;
  CustomerResultPageState(this.customerResult);
  late VideoPlayerController _videoPlayerController;

  @override
  void initState() {
    super.initState();

    // Video dosyanızın yolunu belirtin
    _videoPlayerController =
        VideoPlayerController.asset('assets/images/animated.mp4');

    // Video başlatıldığında otomatik oynatmayı etkinleştirin
    _videoPlayerController.initialize().then((_) {
      setState(() {
        // Video başlatıldığında otomatik oynatmayı etkinleştirin
        _videoPlayerController.play();
      });
    });
  }

  @override
  void dispose() {
    // Controller'ı temizle
    _videoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Geri tuşuna basıldığında istediğiniz sayfaya gitmek için Navigator.push kullanın
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CustomerPage()),
        );
        // WillPopScope, false döndürerek geri tuşunun varsayılan işlevini devre dışı bırakır
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        //* app bar
        appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 64, 73, 83),
          centerTitle: true,
          leading: IconButton(
            color: Colors.white,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CustomerPage()),
              );
            },
            icon: const Icon(
              Icons.arrow_back_ios,
            ),
          ),
          title: Text(
            "Tarama Başarılı",
            // style: Theme.of(context).textTheme.displayLarge,
            style: GoogleFonts.poppins(
              fontSize: 20,
              color: Colors.white,
              letterSpacing: 2,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        //* body
        body: Container(
          padding: const EdgeInsets.all(12),
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //* show QR image
              // QrImageView(
              //   data: customerResult,
              //   size: 200,
              //   version: QrVersions.auto,
              // ),

              //GIF

              GestureDetector(
                onTap: () {
                  // Boş bir onTap fonksiyonu ekleyerek tıklanabilir özelliği devre dışı bırakın
                },
                child: Container(
                  width: 250,
                  height: 250,
                  child: VideoPlayer(_videoPlayerController),
                ),
              ),

              Text(customerResult,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    color: Color.fromARGB(255, 64, 73, 83),
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  )),

              const SizedBox(
                height: 1,
              ),

              // Text(
              //   customerResult,
              //   textAlign: TextAlign.center,
              //   style: Theme.of(context).textTheme.displayMedium,
              // ),

              const SizedBox(
                height: 100,
              ),

              //* tools
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  //* QR Kodu Kopyala
                  ElevatedButton(
                    onPressed: () async {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => CustomerPage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 64, 73, 83),
                      onPrimary: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(50.0), // Kenar yuvarlaklığı
                      ),
                      padding: EdgeInsets.all(10.0), // Düğme iç içe boşluğu
                    ),
                    child: Container(
                      // padding: EdgeInsets.only(top: 10),
                      height: 60,
                      width: 200,
                      decoration: BoxDecoration(color: Colors.transparent),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.qr_code_scanner,
                            color: Colors.white,
                            size: 30,
                          ),
                          const SizedBox(height: 7),
                          Text(
                            'Yeni Tarama',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<Uint8List?> _saveQRCode() async {
    // QR kodunu bir görüntüye dönüştürün
    return await _captureQrCode();
  }

  Future<Uint8List?> _addWhiteBackground(Uint8List qrBytes) async {
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(recorder);

    // Beyaz arkaplanı çizin
    canvas.drawColor(Colors.white, BlendMode.srcOver);

    // QR kodunu çizin
    final ui.Codec codec = await ui.instantiateImageCodec(qrBytes);
    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    final ui.Image image = frameInfo.image;

    final double targetSize = 150.0; // Hedef görüntü boyutu
    final double scaleFactor = targetSize / image.width;
    final double offsetX = (targetSize - image.width * scaleFactor) / 2.0;
    final double offsetY = (targetSize - image.height * scaleFactor) / 2.0;

    final Rect targetRect = Rect.fromLTWH(offsetX, offsetY,
        image.width * scaleFactor, image.height * scaleFactor);
    canvas.drawImageRect(
        image,
        Rect.fromPoints(Offset(0, 0),
            Offset(image.width.toDouble(), image.height.toDouble())),
        targetRect,
        Paint());

    // Resmi bir Uint8List'e dönüştürün
    var finalImage = await recorder
        .endRecording()
        .toImage(targetSize.toInt(), targetSize.toInt());
    var byteData = await finalImage.toByteData(format: ui.ImageByteFormat.png);
    return byteData?.buffer.asUint8List();
  }

  Future<Uint8List?> _captureQrCode() async {
    // QR kodunu oluşturun
    final qrData = customerResult;
    final qrImage = await QrPainter(
      data: qrData,
      version: QrVersions.auto,
      gapless: false,
      color: Colors.black,
      emptyColor: Colors.white,
    ).toImage(200);

    // Uint8List'e dönüştürün
    final ByteData? byteData =
        await qrImage.toByteData(format: ImageByteFormat.png);
    return _addWhiteBackground(byteData!.buffer.asUint8List());
  }

  void _showToast(BuildContext context, String msg) {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      SnackBar(
        content: Text(msg),
      ),
    );
  }
}
