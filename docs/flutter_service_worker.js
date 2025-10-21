'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"assets/AssetManifest.bin": "824a5494fd0319b038c093d0a9965a87",
"assets/AssetManifest.bin.json": "e5a7a7f4abb78d778f8f43132ec95cb9",
"assets/AssetManifest.json": "d50a66922b35e4ad171e3e412e99b115",
"assets/assets/artifacts/EQUIP_BRACER.webp": "367d06b360a298de36da0527fde84e33",
"assets/assets/artifacts/EQUIP_DRESS.webp": "2628581fc36daa98c69f967f11a50300",
"assets/assets/artifacts/EQUIP_NECKLACE.webp": "9a4fa8359daa5b6d8710bb93dc8bce55",
"assets/assets/artifacts/EQUIP_RING.webp": "664fc3ef9345e88193e0dea2cba05b71",
"assets/assets/artifacts/EQUIP_SHOES.webp": "262d6af793a389311ba7131d9f698f7c",
"assets/assets/artifacts/UI_RelicIcon_10007_1.webp": "6038f308ac13a340a1e6505c255585a6",
"assets/assets/artifacts/UI_RelicIcon_10007_2.webp": "843f9bca94540795e290fa4e431575bd",
"assets/assets/artifacts/UI_RelicIcon_10007_3.webp": "6dc855b143f9fd9694c303782b641825",
"assets/assets/artifacts/UI_RelicIcon_10007_4.webp": "8bf1c09fc52cc22d9ec9d94a9d942488",
"assets/assets/artifacts/UI_RelicIcon_10007_5.webp": "905e28a955960256eeedbe36af4933a6",
"assets/assets/artifacts/UI_RelicIcon_14001_1.webp": "a4abdd37ecedde40e472db1a63ab13e2",
"assets/assets/artifacts/UI_RelicIcon_14001_2.webp": "45654700450f35f8dc1afc0770d7724b",
"assets/assets/artifacts/UI_RelicIcon_14001_3.webp": "676ae6452b2f64f18e4ba69c4eba997b",
"assets/assets/artifacts/UI_RelicIcon_14001_4.webp": "16bba601394ea5e9e0e3a78a9e42e3c0",
"assets/assets/artifacts/UI_RelicIcon_14001_5.webp": "b5a557cdc5edf632710cd1193fad5b56",
"assets/assets/artifacts/UI_RelicIcon_14002_1.webp": "5fecf2ac64b60268c51d16abdda85cb1",
"assets/assets/artifacts/UI_RelicIcon_14002_2.webp": "56fd3726249638355456591031e1c4e8",
"assets/assets/artifacts/UI_RelicIcon_14002_3.webp": "3b6c5cffc37e46ce1d83f3f7f6047cfa",
"assets/assets/artifacts/UI_RelicIcon_14002_4.webp": "907f2a0c0a42b6f43570ea7d82a95336",
"assets/assets/artifacts/UI_RelicIcon_14002_5.webp": "ec588d994e1a9dcfe5ca64ebaa03509c",
"assets/assets/artifacts/UI_RelicIcon_14003_1.webp": "99a711e0b800abc7c671d9bd92b310f2",
"assets/assets/artifacts/UI_RelicIcon_14003_2.webp": "705f70e7abb66597a91651e66415a5fc",
"assets/assets/artifacts/UI_RelicIcon_14003_3.webp": "e550a4fb3f4411798c0d0ef1a98f1b44",
"assets/assets/artifacts/UI_RelicIcon_14003_4.webp": "2064c7aa9606fca3b816919e88f3276e",
"assets/assets/artifacts/UI_RelicIcon_14003_5.webp": "6d55a609bfa4304f550d01fde52e21d5",
"assets/assets/artifacts/UI_RelicIcon_14004_1.webp": "efd0d76639913e2123410120d93faecb",
"assets/assets/artifacts/UI_RelicIcon_14004_2.webp": "aab15e3fa6dd9728c0acad54b0fc3c4a",
"assets/assets/artifacts/UI_RelicIcon_14004_3.webp": "0db2d6854ca0e5253c11c6cecc411874",
"assets/assets/artifacts/UI_RelicIcon_14004_4.webp": "93031cb004e99152636cbf4838398332",
"assets/assets/artifacts/UI_RelicIcon_14004_5.webp": "146b0be671d23a1195ebe4673f9196fe",
"assets/assets/artifacts/UI_RelicIcon_15001_1.webp": "fe572c10cf43131230425625c58c1787",
"assets/assets/artifacts/UI_RelicIcon_15001_2.webp": "613b14497ddafc3a586e7df8e4cd84a1",
"assets/assets/artifacts/UI_RelicIcon_15001_3.webp": "c3ae5571c3ea339b7bf88b9be8a34db9",
"assets/assets/artifacts/UI_RelicIcon_15001_4.webp": "d7df230b8b21d69667c0105fbc307f40",
"assets/assets/artifacts/UI_RelicIcon_15001_5.webp": "dbea163193985e91aa94510603c6a209",
"assets/assets/artifacts/UI_RelicIcon_15002_1.webp": "ba97f102598d0e70e0526f053b6f94c2",
"assets/assets/artifacts/UI_RelicIcon_15002_2.webp": "7e0d0a9548e2fe5656cd130070efeecf",
"assets/assets/artifacts/UI_RelicIcon_15002_3.webp": "ad931c7b38c8dd3688e062f1c1ba924b",
"assets/assets/artifacts/UI_RelicIcon_15002_4.webp": "2f8ee833aacb9fc1dddaa9f51a6e6867",
"assets/assets/artifacts/UI_RelicIcon_15002_5.webp": "0d8bd2465bdcdefd3295b83007b484ec",
"assets/assets/artifacts/UI_RelicIcon_15003_1.webp": "1592d36ddbca3d65ee6dd82fad78245f",
"assets/assets/artifacts/UI_RelicIcon_15003_2.webp": "c25187a6382cf8ffc73153ec86449a81",
"assets/assets/artifacts/UI_RelicIcon_15003_3.webp": "0ac44be06725d56787b0465659e19bb1",
"assets/assets/artifacts/UI_RelicIcon_15003_4.webp": "9140802274588720dad0c13ed902a44c",
"assets/assets/artifacts/UI_RelicIcon_15003_5.webp": "e754f8953ff60fa8e8c82e7c78c06598",
"assets/assets/artifacts/UI_RelicIcon_15005_1.webp": "1a04329455f67f584b91e8eb52039d0e",
"assets/assets/artifacts/UI_RelicIcon_15005_2.webp": "bef8e68fdc806545a1ef60880c841d91",
"assets/assets/artifacts/UI_RelicIcon_15005_3.webp": "b4651a6c72bd590d32f173ce93e14773",
"assets/assets/artifacts/UI_RelicIcon_15005_4.webp": "7bf45a4ea310ae9e3e0b1dcdf6c311d6",
"assets/assets/artifacts/UI_RelicIcon_15005_5.webp": "7899cad96d83c6fb57251bb959d11bef",
"assets/assets/artifacts/UI_RelicIcon_15006_1.webp": "e348f764eb04fd4f69a55595c3ee3311",
"assets/assets/artifacts/UI_RelicIcon_15006_2.webp": "6138583c455e4eb3dd6999c98e5ec1be",
"assets/assets/artifacts/UI_RelicIcon_15006_3.webp": "ee8695034405d17d03c357ff36be5618",
"assets/assets/artifacts/UI_RelicIcon_15006_4.webp": "3572fafedc40dbf6346545135fba2a6d",
"assets/assets/artifacts/UI_RelicIcon_15006_5.webp": "2c77216e973aee217f2a8b431b3e1a1f",
"assets/assets/artifacts/UI_RelicIcon_15007_1.webp": "80ca1ef3d9ec42ec144e1d523dc7af5f",
"assets/assets/artifacts/UI_RelicIcon_15007_2.webp": "c39acc5ab29d7aab01b5c926d5627cb7",
"assets/assets/artifacts/UI_RelicIcon_15007_3.webp": "0c9459306e33d2e1dea677b0182be1c3",
"assets/assets/artifacts/UI_RelicIcon_15007_4.webp": "c157d0dee00c133f0d053d15c476bc45",
"assets/assets/artifacts/UI_RelicIcon_15007_5.webp": "9dcc96beac7240f41f1ccf2ce53f9f31",
"assets/assets/artifacts/UI_RelicIcon_15008_1.webp": "4a5e524e3b48687a6ba4d01a89b05d06",
"assets/assets/artifacts/UI_RelicIcon_15008_2.webp": "b0f5a60cc39a18f1bf2845dbbf675f56",
"assets/assets/artifacts/UI_RelicIcon_15008_3.webp": "66d735a659ee7bd57e61ed83f472d35b",
"assets/assets/artifacts/UI_RelicIcon_15008_4.webp": "13512f649c6af6c3e6e96cfb42ffd51f",
"assets/assets/artifacts/UI_RelicIcon_15008_5.webp": "233c861a8a60931a3aed88b502261cf5",
"assets/assets/artifacts/UI_RelicIcon_15014_1.webp": "f4403325e5ccaacb84ba82047727f867",
"assets/assets/artifacts/UI_RelicIcon_15014_2.webp": "e9d16979c75cff0d788f0790d9d39e4e",
"assets/assets/artifacts/UI_RelicIcon_15014_3.webp": "88e0d24820f1fa2ccd42c55bb8dacbe0",
"assets/assets/artifacts/UI_RelicIcon_15014_4.webp": "d67796ba9b6584c46b8df8a5e6f3f85c",
"assets/assets/artifacts/UI_RelicIcon_15014_5.webp": "58c9f3ede1560fc86a3c73626188eca3",
"assets/assets/artifacts/UI_RelicIcon_15015_1.webp": "bc243701573d3155bcd7fc5fe2f4b81a",
"assets/assets/artifacts/UI_RelicIcon_15015_2.webp": "fc10a85d64863e911f76ee15d5e6136a",
"assets/assets/artifacts/UI_RelicIcon_15015_3.webp": "c851a2f704f51f0052173cbe059ec478",
"assets/assets/artifacts/UI_RelicIcon_15015_4.webp": "02e365ea9f481ac2e2cf4bc593a47489",
"assets/assets/artifacts/UI_RelicIcon_15015_5.webp": "bbe9e04ec1c0106136b30403a54ef8ab",
"assets/assets/artifacts/UI_RelicIcon_15016_1.webp": "1abae16d40deb2dd2a3411172baf8f0f",
"assets/assets/artifacts/UI_RelicIcon_15016_2.webp": "de6901e8867b45def0c3542dde81a8b7",
"assets/assets/artifacts/UI_RelicIcon_15016_3.webp": "24c82eb446c675ece9dd7a6aae84d617",
"assets/assets/artifacts/UI_RelicIcon_15016_4.webp": "f4bd7e00e398fd162fae455b7d0e912b",
"assets/assets/artifacts/UI_RelicIcon_15016_5.webp": "eaaf0c2f0efedcdf105d441ecd3be7c3",
"assets/assets/artifacts/UI_RelicIcon_15017_1.webp": "15ba34af1640d6b719c2d0dba049d8d7",
"assets/assets/artifacts/UI_RelicIcon_15017_2.webp": "cfeaeebb358d395e441c63e3863f6036",
"assets/assets/artifacts/UI_RelicIcon_15017_3.webp": "757d1a85eb3d6bc75a60f61150bac463",
"assets/assets/artifacts/UI_RelicIcon_15017_4.webp": "b1baad897950c5520dbf2243aaa68dfc",
"assets/assets/artifacts/UI_RelicIcon_15017_5.webp": "c072dac8eee2b43196bc757a656fbe90",
"assets/assets/artifacts/UI_RelicIcon_15018_1.webp": "e9798c919501e2d56027e7c02b1a130e",
"assets/assets/artifacts/UI_RelicIcon_15018_2.webp": "4b9c5eb0a09d22f1e776d24fc64e720e",
"assets/assets/artifacts/UI_RelicIcon_15018_3.webp": "655c81ab5bcd1286f5c932628f53917e",
"assets/assets/artifacts/UI_RelicIcon_15018_4.webp": "e0c76f638528f8a6294f6d89a18f8616",
"assets/assets/artifacts/UI_RelicIcon_15018_5.webp": "68ea294223251a901d0a35f6e676de77",
"assets/assets/artifacts/UI_RelicIcon_15019_1.webp": "8ae590c23c5d77acb993f2b48775eab9",
"assets/assets/artifacts/UI_RelicIcon_15019_2.webp": "3625cd9ce2d5d38b0e63fb60762b8ac8",
"assets/assets/artifacts/UI_RelicIcon_15019_3.webp": "1e25a6123026e00d3732869984ac360c",
"assets/assets/artifacts/UI_RelicIcon_15019_4.webp": "7f07238f540e32efb5ad193c97885313",
"assets/assets/artifacts/UI_RelicIcon_15019_5.webp": "c9757165e0eb944279e4e169eb7a64cd",
"assets/assets/artifacts/UI_RelicIcon_15020_1.webp": "bcd1a66fec42a1f4f1ab4631ffe6d298",
"assets/assets/artifacts/UI_RelicIcon_15020_2.webp": "cb1e0dcbc0e0ad8ea831cec5dfab2056",
"assets/assets/artifacts/UI_RelicIcon_15020_3.webp": "04c71ec6dbe99256534ca3cc5547822f",
"assets/assets/artifacts/UI_RelicIcon_15020_4.webp": "6a45bfc2394319c71b8fbbb6f29bfde9",
"assets/assets/artifacts/UI_RelicIcon_15020_5.webp": "f724268dfc71d63e39d56f6f96e6273f",
"assets/assets/artifacts/UI_RelicIcon_15021_1.webp": "6a7b5c7683fbbcef847ff79e948235aa",
"assets/assets/artifacts/UI_RelicIcon_15021_2.webp": "463403f7619423b0ed6beb353ede4e94",
"assets/assets/artifacts/UI_RelicIcon_15021_3.webp": "f37f47530ec54de1563e3558924c253f",
"assets/assets/artifacts/UI_RelicIcon_15021_4.webp": "ae0aef7953e8f14d1e6f3421a180fbb8",
"assets/assets/artifacts/UI_RelicIcon_15021_5.webp": "00aebf65b2d1a3b95dca472e873c0611",
"assets/assets/artifacts/UI_RelicIcon_15022_1.webp": "75606bd0bbec57800604dafec23734dc",
"assets/assets/artifacts/UI_RelicIcon_15022_2.webp": "f07f7de1fa7270e080a603691eab65e2",
"assets/assets/artifacts/UI_RelicIcon_15022_3.webp": "09d056c3c2a765e8912f858c27354ef6",
"assets/assets/artifacts/UI_RelicIcon_15022_4.webp": "746ab50e15dafbb185e50c423471fbe0",
"assets/assets/artifacts/UI_RelicIcon_15022_5.webp": "3af1232bb78c3bf8cc7a6abaf15bb1c0",
"assets/assets/artifacts/UI_RelicIcon_15023_1.webp": "e714ee9a45e568392ee92729e2e91727",
"assets/assets/artifacts/UI_RelicIcon_15023_2.webp": "ed9b3e581ed43c56666b92480bafafb5",
"assets/assets/artifacts/UI_RelicIcon_15023_3.webp": "6a5844b9083e6fb8f605bdbf219f2ae6",
"assets/assets/artifacts/UI_RelicIcon_15023_4.webp": "d5c6b6f51f633e9bb53fcfde1457f3d8",
"assets/assets/artifacts/UI_RelicIcon_15023_5.webp": "9565ec078032212fb5a208e639b317b2",
"assets/assets/artifacts/UI_RelicIcon_15024_1.webp": "0d9788ddc21a6a347d099154763e4f33",
"assets/assets/artifacts/UI_RelicIcon_15024_2.webp": "431d8c35887b99fbfabc78518bdad260",
"assets/assets/artifacts/UI_RelicIcon_15024_3.webp": "cf440bcca486579a7bbcc7b9bbd914cc",
"assets/assets/artifacts/UI_RelicIcon_15024_4.webp": "57c9aec689095f94e9b042031e9bf5bf",
"assets/assets/artifacts/UI_RelicIcon_15024_5.webp": "b25958ad628ef251e38ea0acb1b917aa",
"assets/assets/artifacts/UI_RelicIcon_15025_1.webp": "f8c35236b3ea31ab15fda7194bd68566",
"assets/assets/artifacts/UI_RelicIcon_15025_2.webp": "f097a4e0837fd84d439eaed4b77d0d00",
"assets/assets/artifacts/UI_RelicIcon_15025_3.webp": "3674c08e6e7cf4d96372569cfea75476",
"assets/assets/artifacts/UI_RelicIcon_15025_4.webp": "418a2eeb0125f34e946e2fc7a0123f31",
"assets/assets/artifacts/UI_RelicIcon_15025_5.webp": "38b7e3cb361d57044af865224d199a69",
"assets/assets/artifacts/UI_RelicIcon_15026_1.webp": "ff08f16ff3fe49f78f2b4281e969b54d",
"assets/assets/artifacts/UI_RelicIcon_15026_2.webp": "031df714664d3361113b31708b00572c",
"assets/assets/artifacts/UI_RelicIcon_15026_3.webp": "d73d0bcc3278da9171260004ede15cf4",
"assets/assets/artifacts/UI_RelicIcon_15026_4.webp": "61ada9edee1e5d29df9a889f00483841",
"assets/assets/artifacts/UI_RelicIcon_15026_5.webp": "449b4f05611b53c471d214396479cb6f",
"assets/assets/artifacts/UI_RelicIcon_15027_1.webp": "5b4386ee86a96e61a9f63ae4de431db6",
"assets/assets/artifacts/UI_RelicIcon_15027_2.webp": "2ee6ba646409b43c9fed1ca697299e09",
"assets/assets/artifacts/UI_RelicIcon_15027_3.webp": "cf04725132a5a007c88581ca8a353c0d",
"assets/assets/artifacts/UI_RelicIcon_15027_4.webp": "4ab3aef5f35a4cb2448eeb333251f31a",
"assets/assets/artifacts/UI_RelicIcon_15027_5.webp": "eec200da5756652f1ac0af5a58df0f8e",
"assets/assets/artifacts/UI_RelicIcon_15028_1.webp": "84c0bce2e3c0e7539a63f3d59460fc35",
"assets/assets/artifacts/UI_RelicIcon_15028_2.webp": "322587769b691f8c335bd1df4bd299ee",
"assets/assets/artifacts/UI_RelicIcon_15028_3.webp": "966d2e7dd286c688619006f3b6471f88",
"assets/assets/artifacts/UI_RelicIcon_15028_4.webp": "e00685152feeb8355b44260b45a592f3",
"assets/assets/artifacts/UI_RelicIcon_15028_5.webp": "b4f4bd5b98f638db257baf18498f8f4a",
"assets/assets/artifacts/UI_RelicIcon_15029_1.webp": "d30f3e7f417438f0f49ade4c0f80dbd2",
"assets/assets/artifacts/UI_RelicIcon_15029_2.webp": "62a129b3198aedbeb0bea874901e2756",
"assets/assets/artifacts/UI_RelicIcon_15029_3.webp": "76acc0542db2a6ab2bd7d6554fdbc17a",
"assets/assets/artifacts/UI_RelicIcon_15029_4.webp": "f0d1b487d88f20eb547ea3d8a0e7a0b5",
"assets/assets/artifacts/UI_RelicIcon_15029_5.webp": "6468323084330559f4677c03f599a02e",
"assets/assets/artifacts/UI_RelicIcon_15030_1.webp": "742dbc21dd4d6030e61d85a415abbff9",
"assets/assets/artifacts/UI_RelicIcon_15030_2.webp": "4f9d423fb948e6b89405d82fa141a788",
"assets/assets/artifacts/UI_RelicIcon_15030_3.webp": "6cedcc269b6ca40a8a522f36b0f941e6",
"assets/assets/artifacts/UI_RelicIcon_15030_4.webp": "bd2826d332a2cedb3d1af71389ff0ad5",
"assets/assets/artifacts/UI_RelicIcon_15030_5.webp": "3e7a360abb92d07450ca1dbe7f4093a9",
"assets/assets/artifacts/UI_RelicIcon_15031_1.webp": "ca4e20773aee76e782c2b36e236d447a",
"assets/assets/artifacts/UI_RelicIcon_15031_2.webp": "9f6c80808a17074ecad6a866f4c88901",
"assets/assets/artifacts/UI_RelicIcon_15031_3.webp": "78f5af02cfb5e90165c6f91c07f8ea87",
"assets/assets/artifacts/UI_RelicIcon_15031_4.webp": "3792f2330fd80953fa73108ef43a3d46",
"assets/assets/artifacts/UI_RelicIcon_15031_5.webp": "09ee975b384b9df3b2f8661d41e409cb",
"assets/assets/artifacts/UI_RelicIcon_15032_1.webp": "629b7cd496a62778feb67e10218ce13b",
"assets/assets/artifacts/UI_RelicIcon_15032_2.webp": "511bb7d5c4877af256384ced52542ad6",
"assets/assets/artifacts/UI_RelicIcon_15032_3.webp": "c6c58e6a1f4dcd6c1db829c81f63d585",
"assets/assets/artifacts/UI_RelicIcon_15032_4.webp": "75fbf87c2535b6a6036194d219a8aa83",
"assets/assets/artifacts/UI_RelicIcon_15032_5.webp": "0a42b7e75364d405a9a96e73fdb8a773",
"assets/assets/artifacts/UI_RelicIcon_15033_1.webp": "a974179b3d389c2e54b86cde7a53c019",
"assets/assets/artifacts/UI_RelicIcon_15033_2.webp": "3a93370c7f84c935f7703c200dc0ac45",
"assets/assets/artifacts/UI_RelicIcon_15033_3.webp": "23812da8575d4fc2b0d8f7be192712c8",
"assets/assets/artifacts/UI_RelicIcon_15033_4.webp": "7f1d0b20a8653dad052cf6a569b40f93",
"assets/assets/artifacts/UI_RelicIcon_15033_5.webp": "5f59f4fa9261e9d1ab422af15a966c93",
"assets/assets/artifacts/UI_RelicIcon_15034_1.webp": "32cffabecd4552c0a05e18bf99476055",
"assets/assets/artifacts/UI_RelicIcon_15034_2.webp": "b5e5723579d668f39030f1d6c27347f4",
"assets/assets/artifacts/UI_RelicIcon_15034_3.webp": "c5722ca00adefb747f3f1bb352b23ca7",
"assets/assets/artifacts/UI_RelicIcon_15034_4.webp": "8cfe4b953fa2919ebd0dfd9e426792ed",
"assets/assets/artifacts/UI_RelicIcon_15034_5.webp": "9a65aa156b9a230d22f25a3b69441687",
"assets/assets/artifacts/UI_RelicIcon_15035_1.webp": "698f895c0205e0c0d9edff8eee094bd4",
"assets/assets/artifacts/UI_RelicIcon_15035_2.webp": "cd8c8861336506c6b0356e6be664a198",
"assets/assets/artifacts/UI_RelicIcon_15035_3.webp": "7bcca2d5135c946a25a82b55b90ca126",
"assets/assets/artifacts/UI_RelicIcon_15035_4.webp": "ef3fe117468066a997bca49959de929b",
"assets/assets/artifacts/UI_RelicIcon_15035_5.webp": "07cd088f3214a2e3a386a5003198876c",
"assets/assets/artifacts/UI_RelicIcon_15036_1.webp": "7532142f74850fc63a74c78243a14a00",
"assets/assets/artifacts/UI_RelicIcon_15036_2.webp": "a03564ad90712579fe7fc0653d7c21e2",
"assets/assets/artifacts/UI_RelicIcon_15036_3.webp": "ca13255cf9abc30fb12aa12c21cb663e",
"assets/assets/artifacts/UI_RelicIcon_15036_4.webp": "f2c4adce2bf879306c5be51062f18537",
"assets/assets/artifacts/UI_RelicIcon_15036_5.webp": "e10e51191b1e1b18b66680c5e586db6c",
"assets/assets/artifacts/UI_RelicIcon_15037_1.webp": "1025f6192e7e633445d9f3ff5c09211d",
"assets/assets/artifacts/UI_RelicIcon_15037_2.webp": "fd1cc3719afe02b8833d8eeee2a98167",
"assets/assets/artifacts/UI_RelicIcon_15037_3.webp": "e00270659c1aabc57c0103959f301e20",
"assets/assets/artifacts/UI_RelicIcon_15037_4.webp": "22d39b50f76a5c8f78c9d3a83ca46031",
"assets/assets/artifacts/UI_RelicIcon_15037_5.webp": "76785409539d289ebb18cc58dc98e9a0",
"assets/assets/artifacts/UI_RelicIcon_15038_1.webp": "7ace710f142235734ea104451357afea",
"assets/assets/artifacts/UI_RelicIcon_15038_2.webp": "5245b8d6e17a763f5d031864808f868b",
"assets/assets/artifacts/UI_RelicIcon_15038_3.webp": "f6901d1ae5800e69575117554f55b3a1",
"assets/assets/artifacts/UI_RelicIcon_15038_4.webp": "1320a81cac3014a32e2eae26b16064cb",
"assets/assets/artifacts/UI_RelicIcon_15038_5.webp": "0435a8b307c9d8cce0b9467cfbd1436b",
"assets/assets/artifacts/UI_RelicIcon_15039_1.webp": "9af6ccbcc603c0e22ebe2b39155691e0",
"assets/assets/artifacts/UI_RelicIcon_15039_2.webp": "d444a4efe937557c0a2be5e2411bc359",
"assets/assets/artifacts/UI_RelicIcon_15039_3.webp": "7178286e13741ecbd1361555ba1fa3d6",
"assets/assets/artifacts/UI_RelicIcon_15039_4.webp": "1c09bc62434642351aa2e473586605db",
"assets/assets/artifacts/UI_RelicIcon_15039_5.webp": "7d784e8e3da0d1290422da9d3e0a2864",
"assets/assets/artifacts/UI_RelicIcon_15040_1.webp": "b634fecb4ee09cea5b883b3f8de07863",
"assets/assets/artifacts/UI_RelicIcon_15040_2.webp": "a93b0a173ccf359a8c272aed5a7d238b",
"assets/assets/artifacts/UI_RelicIcon_15040_3.webp": "cc355fdab8c7280232b8a2d42b9e49f6",
"assets/assets/artifacts/UI_RelicIcon_15040_4.webp": "5bcbd03fd78617b1a8ad0d1b538f1f2a",
"assets/assets/artifacts/UI_RelicIcon_15040_5.webp": "ed4d8639b80bcdbe4ff5c259da227991",
"assets/assets/artifacts/UI_RelicIcon_15041_1.webp": "20c3fde7ea3a8088c0532fc5b34177da",
"assets/assets/artifacts/UI_RelicIcon_15041_2.webp": "0c839ba1e785286df34be0aae26a1104",
"assets/assets/artifacts/UI_RelicIcon_15041_3.webp": "d39d498418f4a208e6cce8f0b5029ff2",
"assets/assets/artifacts/UI_RelicIcon_15041_4.webp": "e128b6a1dd68a025d16bf87e971bb860",
"assets/assets/artifacts/UI_RelicIcon_15041_5.webp": "c35cba388d70b1da4167d7ddb427f985",
"assets/assets/artifacts/UI_RelicIcon_15042_1.webp": "296fcc561b75b02881b69b4747d03de0",
"assets/assets/artifacts/UI_RelicIcon_15042_2.webp": "3e472aeb95d17f1785bc1aaaeb774a1f",
"assets/assets/artifacts/UI_RelicIcon_15042_3.webp": "a3fa21a6432747e133ea709b26eb995a",
"assets/assets/artifacts/UI_RelicIcon_15042_4.webp": "05385b0cd750f8a01d23645ffea54bfc",
"assets/assets/artifacts/UI_RelicIcon_15042_5.webp": "9aa9b66fe7dd23b95e0048f497e4df7b",
"assets/assets/fonts/GISDK/ja-jp.ttf": "23bdc45e735a90352edb62487ab2c3ab",
"assets/assets/fonts/GISDK/zh-cn.ttf": "1d9f35d597a2461b3125dc760034a1e9",
"assets/assets/json/stats_append.json": "e592ed966f35f3fa16c2f1938d4feaa8",
"assets/assets/json/stats_l18n.json": "55e55d5a799e745cb4da26e5eff8dc41",
"assets/assets/json/userdata.json": "faec14518be8f395aa9ce8de893be638",
"assets/FontManifest.json": "f7076a64f277ace2b48526b31cf737c2",
"assets/fonts/MaterialIcons-Regular.otf": "73ca91b7fa533a390449d076921b2e70",
"assets/NOTICES": "1fef8d380430350eadea4acdd39032ef",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"canvaskit/canvaskit.js": "140ccb7d34d0a55065fbd422b843add6",
"canvaskit/canvaskit.js.symbols": "58832fbed59e00d2190aa295c4d70360",
"canvaskit/canvaskit.wasm": "07b9f5853202304d3b0749d9306573cc",
"canvaskit/chromium/canvaskit.js": "5e27aae346eee469027c80af0751d53d",
"canvaskit/chromium/canvaskit.js.symbols": "193deaca1a1424049326d4a91ad1d88d",
"canvaskit/chromium/canvaskit.wasm": "24c77e750a7fa6d474198905249ff506",
"canvaskit/skwasm.js": "1ef3ea3a0fec4569e5d531da25f34095",
"canvaskit/skwasm.js.symbols": "0088242d10d7e7d6d2649d1fe1bda7c1",
"canvaskit/skwasm.wasm": "264db41426307cfc7fa44b95a7772109",
"canvaskit/skwasm_heavy.js": "413f5b2b2d9345f37de148e2544f584f",
"canvaskit/skwasm_heavy.js.symbols": "3c01ec03b5de6d62c34e17014d1decd3",
"canvaskit/skwasm_heavy.wasm": "8034ad26ba2485dab2fd49bdd786837b",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"flutter.js": "888483df48293866f9f41d3d9274a779",
"flutter_bootstrap.js": "f83fbf9804eea78b0fa0354810cc6fcb",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"index.html": "6a0841191e2fb3fea6294982a8f8e605",
"/": "6a0841191e2fb3fea6294982a8f8e605",
"main.dart.js": "3182c2dccc7e9777e79ff5e47c3d51df",
"manifest.json": "8809bb2a94e643f03adf2499b619c22e",
"version.json": "0caedec050c54cf6c8997c026cf0754c"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
