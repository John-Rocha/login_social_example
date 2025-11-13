# Login Social Example

Aplicativo Flutter demonstrando implementação de autenticação social com Google e Facebook usando Firebase Auth, seguindo princípios de Clean Architecture e gerenciamento de estado com BLoC.

## Características

- Autenticação com Google Sign-In
- Autenticação com Facebook Login
- Fotos de perfil em alta resolução (especialmente para Facebook)
- Persistência de sessão após hot-reload
- Gerenciamento de estado com BLoC/Cubit
- Arquitetura limpa e escalável
- Injeção de dependências com GetIt
- Roteamento com GoRouter

## Arquitetura

O projeto segue os princípios de **Clean Architecture**, separando responsabilidades em camadas:

```
lib/
├── core/
│   ├── errors/           # Exceções e falhas
│   ├── injection/        # Configuração de injeção de dependências
│   └── routes/           # Configuração de rotas
├── feature/
│   └── social_login/
│       ├── data/
│       │   ├── models/           # Modelos de dados
│       │   ├── repositories/     # Implementação dos repositórios
│       │   └── services/         # Serviços de autenticação (Google, Facebook)
│       ├── domain/
│       │   ├── entities/         # Entidades de domínio
│       │   └── repositories/     # Contratos de repositório
│       └── presenter/
│           ├── cubit/            # Gerenciamento de estado
│           └── pages/            # Páginas da aplicação
└── main.dart
```

### Camadas

#### Domain (Domínio)
- **Entities**: Classes de domínio puras (`UserEntity`)
- **Repositories**: Interfaces que definem contratos de dados

#### Data (Dados)
- **Models**: Implementações concretas das entidades com serialização
- **Repositories**: Implementações dos contratos de repositório
- **Services**: Serviços de autenticação para Google e Facebook

#### Presentation (Apresentação)
- **Cubit**: Gerenciamento de estado com `AuthCubit`
- **Pages**: UI com `LoginPage` e `HomePage`

## Tecnologias

### Core
- **Flutter SDK**: ^3.9.2
- **Dart**: ^3.9.2

### Firebase
- **firebase_core**: ^4.2.1
- **firebase_auth**: ^6.1.2

### Autenticação Social
- **google_sign_in**: ^7.2.0
- **flutter_facebook_auth**: ^7.1.2

### Gerenciamento de Estado
- **flutter_bloc**: ^8.1.6
- **equatable**: ^2.0.7

### Utilitários
- **dartz**: ^0.10.1 (Programação funcional)
- **get_it**: ^8.0.3 (Injeção de dependências)
- **go_router**: ^14.6.2 (Roteamento)

## Configuração

### 1. Pré-requisitos

- Flutter instalado (versão 3.9.2 ou superior)
- Conta no [Firebase Console](https://console.firebase.google.com/)
- Conta no [Facebook Developers](https://developers.facebook.com/)
- Conta no [Google Cloud Console](https://console.cloud.google.com/)

### 2. Configuração do Firebase

1. Crie um projeto no Firebase Console
2. Adicione um app Android e/ou iOS ao projeto
3. Baixe os arquivos de configuração:
   - Android: `google-services.json` → `android/app/`
   - iOS: `GoogleService-Info.plist` → `ios/Runner/`
4. Habilite os métodos de autenticação no Firebase Console:
   - Authentication → Sign-in method → Google (Ativar)
   - Authentication → Sign-in method → Facebook (Ativar)

### 3. Configuração do Google Sign-In

#### Android

1. No Firebase Console, vá em Project Settings → General
2. Copie o **Web client ID** do OAuth 2.0
3. No arquivo [google_sign_in_service.dart](lib/feature/social_login/data/services/google_sign_in_service.dart), atualize o `serverClientId`:

```dart
await _googleSignIn.initialize(
  serverClientId: 'SEU_WEB_CLIENT_ID_AQUI',
);
```

4. Certifique-se de que o SHA-1 do seu app está registrado no Firebase:

```bash
# Para debug keystore
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android

# Adicione o SHA-1 no Firebase Console → Project Settings → Your apps → Android app
```

#### iOS

1. Adicione o URL Scheme no `ios/Runner/Info.plist`:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <!-- Google Sign-In -->
            <string>com.googleusercontent.apps.SEU_REVERSED_CLIENT_ID</string>
        </array>
    </dict>
</array>
```

### 4. Configuração do Facebook Login

#### Criando o App no Facebook

1. Acesse [Facebook Developers](https://developers.facebook.com/)
2. Crie um novo app ou use um existente
3. Adicione o produto "Facebook Login"
4. Configure os seguintes parâmetros:

**Settings → Basic:**
- App Domains: `localhost`
- Privacy Policy URL: (sua URL)

**Facebook Login → Settings:**
- Valid OAuth Redirect URIs:
  ```
  https://SEU_PROJETO.firebaseapp.com/__/auth/handler
  ```

#### Android

1. No `android/app/src/main/res/values/strings.xml`:

```xml
<resources>
    <string name="app_name">Login Social Example</string>
    <string name="facebook_app_id">SEU_FACEBOOK_APP_ID</string>
    <string name="fb_login_protocol_scheme">fbSEU_FACEBOOK_APP_ID</string>
    <string name="facebook_client_token">SEU_FACEBOOK_CLIENT_TOKEN</string>
</resources>
```

2. No `android/app/src/main/AndroidManifest.xml`:

```xml
<application>
    <!-- Adicione dentro da tag application -->
    <meta-data
        android:name="com.facebook.sdk.ApplicationId"
        android:value="@string/facebook_app_id"/>

    <meta-data
        android:name="com.facebook.sdk.ClientToken"
        android:value="@string/facebook_client_token"/>

    <activity
        android:name="com.facebook.FacebookActivity"
        android:configChanges="keyboard|keyboardHidden|screenLayout|screenSize|orientation"
        android:label="@string/app_name" />
</application>
```

3. Gere e registre o Hash Key:

```bash
# Para debug keystore
keytool -exportcert -alias androiddebugkey -keystore ~/.android/debug.keystore | openssl sha1 -binary | openssl base64

# Adicione o hash no Facebook Developers → Settings → Android → Key Hashes
```

#### iOS

1. No `ios/Runner/Info.plist`:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>fbSEU_FACEBOOK_APP_ID</string>
        </array>
    </dict>
</array>

<key>FacebookAppID</key>
<string>SEU_FACEBOOK_APP_ID</string>
<key>FacebookClientToken</key>
<string>SEU_FACEBOOK_CLIENT_TOKEN</string>
<key>FacebookDisplayName</key>
<string>Login Social Example</string>

<key>LSApplicationQueriesSchemes</key>
<array>
    <string>fbapi</string>
    <string>fb-messenger-share-api</string>
</array>
```

2. Adicione o Bundle ID no Facebook Developers → Settings → iOS

### 5. Firebase no Código

O arquivo [firebase_options.dart](lib/firebase_options.dart) é gerado automaticamente usando:

```bash
firebase login
flutterfire configure
```

### 6. Instalar Dependências

```bash
flutter pub get
```

## Executando o App

```bash
# Debug
flutter run

# Release
flutter run --release
```

## Funcionalidades Implementadas

### Autenticação com Google
- Login com conta Google
- Foto de perfil carregada do Google
- Persistência de sessão
- Logout

### Autenticação com Facebook
- Login com conta Facebook
- **Foto de perfil em alta resolução** (500x500px) carregada diretamente da Graph API
- Persistência de sessão mesmo após hot-reload
- Logout

### Detalhes Técnicos da Foto do Facebook

O app implementa uma solução especial para fotos do Facebook:

1. **No login**: Busca a foto em alta resolução via Graph API ([auth_repository_impl.dart:55-67](lib/feature/social_login/data/repositories/auth_repository_impl.dart#L55-L67))
2. **No hot-reload**: Detecta usuários logados com Facebook e recarrega a foto ([auth_repository_impl.dart:107-124](lib/feature/social_login/data/repositories/auth_repository_impl.dart#L107-L124))
3. **Fallback**: Se falhar, usa a foto do Firebase Auth

Isso garante que a foto do perfil do Facebook sempre seja exibida em alta qualidade, diferentemente da foto padrão do Firebase Auth que tem baixa resolução.

## Gerenciamento de Estado

O app usa **BLoC Pattern** com Cubit para gerenciar estados de autenticação:

### Estados
- `AuthInitial`: Estado inicial
- `AuthLoading`: Carregando operação de autenticação
- `AuthAuthenticated`: Usuário autenticado
- `AuthUnauthenticated`: Usuário não autenticado
- `AuthError`: Erro na autenticação

### Eventos (Métodos do Cubit)
- `signInWithGoogle()`: Iniciar login com Google
- `signInWithFacebook()`: Iniciar login com Facebook
- `signOut()`: Fazer logout
- `getCurrentUser()`: Verificar usuário atual (privado)

## Tratamento de Erros

O app implementa um sistema robusto de tratamento de erros:

### Exceções Customizadas
- `AuthException`: Erros de autenticação genéricos
- `CancelledByUserException`: Login cancelado pelo usuário

### Failures (Falhas)
- `AuthFailure`: Falhas de autenticação com mensagem descritiva
- `CancelledByUserFailure`: Cancelamento pelo usuário

## Estrutura de Pastas Completa

```
lib/
├── core/
│   ├── errors/
│   │   ├── exceptions.dart
│   │   └── failures.dart
│   ├── injection/
│   │   └── injection_container.dart
│   └── routes/
│       └── app_router.dart
├── feature/
│   └── social_login/
│       ├── data/
│       │   ├── models/
│       │   │   └── user_model.dart
│       │   ├── repositories/
│       │   │   └── auth_repository_impl.dart
│       │   └── services/
│       │       ├── facebook_sign_in_service.dart
│       │       └── google_sign_in_service.dart
│       ├── domain/
│       │   ├── entities/
│       │   │   └── user_entity.dart
│       │   └── repositories/
│       │       └── auth_repository.dart
│       └── presenter/
│           ├── cubit/
│           │   ├── auth_cubit.dart
│           │   └── auth_state.dart
│           └── pages/
│               ├── home_page.dart
│               └── login_page.dart
├── firebase_options.dart
└── main.dart
```

## Solução de Problemas

### Foto do Facebook não aparece após hot-reload
✅ **Resolvido**: O app agora busca automaticamente a foto em alta resolução do Facebook ao detectar um hot-reload.

### Erro: PlatformException(sign_in_failed)
- Verifique se o SHA-1 está registrado no Firebase
- Confirme que o `serverClientId` está correto
- Certifique-se de que o Google Sign-In está habilitado no Firebase Console

### Erro: FacebookLoginException
- Verifique se o App ID e Client Token estão corretos
- Confirme que o Hash Key do Android está registrado no Facebook
- Verifique se o Bundle ID do iOS está configurado no Facebook

### Erro: FirebaseException
- Verifique se os arquivos `google-services.json` (Android) ou `GoogleService-Info.plist` (iOS) estão no local correto
- Confirme que o Firebase está inicializado no `main.dart`

## Próximos Passos

Sugestões de melhorias:

- [ ] Adicionar testes unitários e de widget
- [ ] Implementar Apple Sign-In
- [ ] Adicionar autenticação com email/senha
- [ ] Implementar recuperação de senha
- [ ] Adicionar loading indicators mais elaborados
- [ ] Implementar cache local da foto do perfil
- [ ] Adicionar analytics
- [ ] Implementar deep linking

## Licença

Este projeto é um exemplo educacional e está disponível para uso livre.

## Autor

João Rocha

---

Desenvolvido com Flutter ❤️
