import 'package:flutter/material.dart';

import '../../data/models/place_model.dart';
import '../widgets/place_card_with_description.dart';

/// 📍 Screen to show featured places with descriptions
class FeaturedPlacesScreen extends StatelessWidget {
  const FeaturedPlacesScreen({super.key});

  // Mock data with descriptions from our database
  List<PlaceModel> get _mockPlaces => [
        PlaceModel(
          id: 'gullfoss',
          name: 'Gullfoss',
          type: 'waterfall',
          lat: 64.3271,
          lng: -20.1211,
          rating: 4.9,
          description:
              'Gullfoss, "Gullna fossinn", er einn frægusti og stórkostlegusti foss Íslands. Fossinn fellur í tveimur þrepum samtals 32 metra niður í Hvítárgljúfur. Mikill kraftur og máttur náttúrunnar sýnir sig hér á dramatískan hátt.',
          images: [
            'https://images.unsplash.com/photo-1531366936337-7c912a4589a7'
          ],
          meta: {'region': 'Suðurland'},
        ),
        PlaceModel(
          id: 'jokulsarlon',
          name: 'Jökulsárlón',
          type: 'glacier',
          lat: 64.0484,
          lng: -16.1806,
          rating: 4.9,
          description:
              'Jökulsárlón er stærsta og frægasta jökullón Íslands. Ísjakarnir sem fljóta í lóninu og stranda á Demantaströnd eru ótrúleg sjón. Selir sjást oft í lóninu. Einn vinsælasti ferðamannastadur landsins.',
          images: [
            'https://images.unsplash.com/photo-1469854523086-cc02fe5d8800'
          ],
          meta: {'region': 'Austurland'},
        ),
        PlaceModel(
          id: 'blue-lagoon',
          name: 'Blue Lagoon',
          type: 'hot_spring',
          lat: 63.8804,
          lng: -22.4495,
          rating: 4.5,
          description:
              'Bláa lónið er heimsfrægasta heilsulaug Íslands með 37-39°C heitu sjávarvatni. Kísilríkt vatn sem gott er fyrir húðina. Lúxus spa upplifun í hraunlandslagi.',
          images: [
            'https://images.unsplash.com/photo-1578307985320-9c246eda01a1'
          ],
          meta: {'region': 'Suðurnes'},
        ),
        PlaceModel(
          id: 'reynisfjara',
          name: 'Reynisfjara',
          type: 'beach',
          lat: 63.4042,
          lng: -19.0450,
          rating: 4.8,
          description:
              'Reynisfjara er fallegasti svarti sandströndin á Íslandi með Reynisdröngum, basaltsúlum og Dyrhólaey fuglabjargi. Öflugar öldubreytingar - vertu varkár! Einstök náttúra.',
          images: [
            'https://images.unsplash.com/photo-1483354483454-4cd359948304'
          ],
          meta: {'region': 'Suðurland'},
        ),
        PlaceModel(
          id: 'kirkjufell',
          name: 'Kirkjufell',
          type: 'viewpoint',
          lat: 64.9242,
          lng: -23.3122,
          rating: 4.8,
          description:
              'Kirkjufell á Snæfellsnesi er eitt þekktasta fjall Íslands. Sást í Game of Thrones. Fullkomið form og fallegur foss við fótinn (Kirkjufellsfoss). Vinsælasti ljósmyndastaður fyrir norðurljós.',
          images: [
            'https://images.unsplash.com/photo-1504893524553-b855bce32c67'
          ],
          meta: {'region': 'Vesturland'},
        ),
        PlaceModel(
          id: 'geysir',
          name: 'Geysir',
          type: 'hot_spring',
          lat: 64.3102,
          lng: -20.3030,
          rating: 4.7,
          description:
              'Geysir er frægasti goshverinn í heimi og gaf nafn öllum öðrum goshverum. Þó Geysir sjálfur sé óvirkur, gýs Strokkur á 5-10 mínútna fresti upp í 20-40 metra hæð. Ótrúleg náttúruupplifun.',
          images: [
            'https://images.unsplash.com/photo-1531366936337-7c912a4589a7'
          ],
          meta: {'region': 'Suðurland'},
        ),
        PlaceModel(
          id: 'dettifoss',
          name: 'Dettifoss',
          type: 'waterfall',
          lat: 65.8147,
          lng: -16.3850,
          rating: 4.9,
          description:
              'Dettifoss er öflugasti foss Evrópu með 100 metra breiddina og 44 metra hæð. Fossinn er á Jökulsá á Fjöllum og ótrúlegur kraftur vatnssins má finna hér. Stórfengleg náttúruupplifun.',
          images: [
            'https://images.unsplash.com/photo-1483347756197-71ef80e95f73'
          ],
          meta: {'region': 'Norðurland'},
        ),
        PlaceModel(
          id: 'skogafoss',
          name: 'Skógafoss',
          type: 'waterfall',
          lat: 63.5320,
          lng: -19.5114,
          rating: 4.9,
          description:
              'Skógafoss er einn fallegasti foss Íslands, 60 metra hár og 25 metra breiður. Fossinn er oft með fallegum regnboga í sólskini. Hægt er að ganga upp að toppi fossins og sjá útsýni yfir suðurströndina.',
          images: [
            'https://images.unsplash.com/photo-1506905925346-21bda4d32df4'
          ],
          meta: {'region': 'Suðurland'},
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Helstu Ferðamannastaðir'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _mockPlaces.length,
        itemBuilder: (context, index) {
          return PlaceCardWithDescription(
            place: _mockPlaces[index],
          );
        },
      ),
    );
  }
}
