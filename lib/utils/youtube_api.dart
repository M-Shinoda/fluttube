import 'package:fluttube/main.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:yt/yt.dart';

import '../models/youtube_model.dart';

// late final ytApi = Yt.withKey('AIzaSyAM2qP2XwtD5-9C0q7F5mtCnTuk2VCn1xA');
// late final ytApi;

Future<List<MyPlaylist>?> getMyChannelPlaylistOnlyPublic() async {
  // final f = await Yt.withGenerator(YtLoginGenerator());

  // print((await f.videos.list(id: 'Rf9b9O5tDY8')).items.first.snippet!.title);
  // inspect(await f.playlists.list(mine: true));

  try {
    final res = await ytApi.playlists.list(mine: true, maxResults: 100);
    return res.items.map((e) {
      return MyPlaylist.fromPlaylist(e);
    }).toList();
  } catch (e) {
    print(e);
  }
  return null;
}

class YtLoginGenerator implements TokenGenerator {
  final GoogleSignIn _googleSignIn =
      GoogleSignIn(scopes: ['https://www.googleapis.com/auth/youtube']);

  @override
  Future<Token> generate() async {
    var currentUser = await _googleSignIn.signInSilently();

    currentUser ??= await _googleSignIn.signIn();

    final token = (await currentUser!.authentication).accessToken;

    if (token == null) throw Exception();

    return Token(
        accessToken: token, expiresIn: 3599, scope: null, tokenType: '');
  }
}
