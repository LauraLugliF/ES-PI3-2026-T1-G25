# 📈 **MesclaInvest**

O MesclaInvest é um aplicativo mobile que simula uma plataforma de investimento em startups do ecossistema **Mescla**, permitindo que usuários visualizem projetos, acompanhem informações e realizem **negociações simuladas de tokens** representando participações digitais.

Este repositório contém o desenvolvimento do sistema proposto na disciplina.

## 🧩 Estrutura do repositório

- **Parte do app:** `MesclaInvest/lib`, `MesclaInvest/android`, `MesclaInvest/ios` e `MesclaInvest/web`
- **Parte lógica / backend:** `MesclaInvest/functions` (Cloud Functions, regras e integrações Firebase)
- **Artefato de release:** `MesclaInvest/APP/Mesclainvest.apk`
- **Documentação e materiais:** `Orientações Renata`

---

## 👥 Integrantes

| Nome | RA |
|------|----|
| Ana Beatriz da Silva | 25007143 |
| Arthur Grizone Silvestre de Oliveira | 25008341 |
| Laura Lugli Fonseca Pereira | 25000739 |
| Lucas Rodrigues Xavier | 25000508 |
| Maria Júlia Souza de Oliveira | 25007909 |
| Max Thomazini Barboza | 25003834 |

---

## 🛠 Tecnologias

O projeto será desenvolvido utilizando:

- **Flutter (Dart)** – Aplicação Mobile  
- **Node.js (JavaScript / TypeScript)** – Backend  
- **Firebase Firestore** – Banco de dados  
- **Git + GitHub** – Controle de versão  

---

## 🎓 Disciplina

**Projeto Integrador III – 2026**  
Curso: Engenharia de Software  
Instituição: PUC-Campinas

---

## 📁 Pasta Orientações Renata

Esta pasta reúne os materiais elaborados a partir das orientações recebidas que não envolvam programação nem alterações diretas no código.

---

## ⚙️ Pasta MesclaInvest

Esta pasta concentra o projeto completo, com a parte visual do app, a parte lógica do backend e os recursos de build e teste.

### Parte do app

- Interface e navegação em `lib/`
- Configuração mobile em `android/`, `ios/` e `web/`
- Testes da aplicação em `test/`

### Parte lógica

- Cloud Functions e integrações Firebase em `functions/`
- Regras e índices do Firestore em `firestore.rules` e `firestore.indexes.json`
- Regras de Storage em `storage.rules`

### Release do app

- APK pronto para uso em `APP/Mesclainvest.apk`

## 📲 Como usar a versão release do app

Use esta versão quando quiser abrir o app já compilado, sem rodar o projeto Flutter no computador.

1. Baixe o APK em `MesclaInvest/APP/Mesclainvest.apk`.
2. Copie o arquivo para um celular Android ou para o emulador.
3. No Android, ative a opção de instalar apps de fontes desconhecidas, se o sistema solicitar.
4. Abra o arquivo `Mesclainvest.apk` e confirme a instalação.
5. Depois de instalado, abra o ícone do MesclaInvest normalmente.

Se estiver usando um emulador Android, você também pode instalar o APK arrastando o arquivo para a tela do emulador ou usando o comando:

```powershell
adb install -r MesclaInvest/APP/Mesclainvest.apk
```

Essa versão já contém a lógica do aplicativo e pode ser usada para demonstração e testes de uso, sem precisar compilar o projeto novamente.

Se o SMS de MFA não chegar durante os testes, use o número `+5519998552511` com o código de teste `123456` para continuar a validação.

## 📌 Descrição do projeto

O MesclaInvest é um aplicativo mobile que simula uma plataforma de investimento em startups do ecossistema Mescla. Usuários podem visualizar projetos, acompanhar informações financeiras e realizar negociações simuladas de tokens que representam participações digitais nas startups.

## 🧾 Como executar em ambiente de testes

- **Pré-requisitos**:
	- Flutter (versão compatível com o projeto) instalado e configurado
	- Android SDK / Xcode (para executar em emuladores ou dispositivos físicos)
	- Node.js (para funções Firebase)
	- Firebase CLI (`npm install -g firebase-tools`) para emuladores

- **Executando o backend (Cloud Functions / emuladores Firebase)**:

	1. Abra um terminal e vá para a pasta das funções:

		 ```powershell
		 cd MesclaInvest/functions
		 npm install
		 ```

	2. Inicie os emuladores do Firebase (Firestore, Auth e Functions):

		 ```powershell
		 firebase emulators:start --only firestore,auth,functions
		 ```

	Observação: os emuladores permitem testar a aplicação sem alterar o projeto em produção.

- **Executando o aplicativo Flutter (mobile)**:

	1. No terminal, vá para a pasta do app:

		 ```powershell
		 cd MesclaInvest
		 flutter pub get
		 ```

	2. Execute no emulador ou dispositivo conectado:

		 ```powershell
		 flutter run -d <device-id>
		 ```

	Substitua `<device-id>` pelo id do dispositivo retornado por `flutter devices`, ou remova a opção `-d` para escolher pelo IDE.

- **Emulador Android (Pixel 4)**:

	- Pelo Android Studio (GUI):
		1. Abra o Android Studio e, se ainda não importou o projeto, vá em `File > Open` e selecione a pasta `MesclaInvest`.
		2. Verifique se os plugins **Flutter** e **Dart** estão instalados: `File > Settings > Plugins` (procure por "Flutter").
		3. Abra o `AVD Manager` pelo menu `Tools > AVD Manager`.
		4. Clique em **Create Virtual Device** e escolha `Phone > Pixel 4`, clique em **Next**.
		5. Selecione uma **System Image** compatível (recomenda-se API 30+; escolha uma imagem com ABI `x86` ou `x86_64` para melhor desempenho). Se necessário, clique em **Download** ao lado da imagem e aguarde a instalação.
		6. Revise as configurações do AVD (nome, memória, resolução). Em **Advanced Settings** ajuste `Graphics` para `Hardware - GLES 2.0` ou `Automatic` para melhor performance quando suportado.
		7. Clique em **Finish** para criar o AVD.
		8. Inicie o emulador clicando no ícone de play (▶) ao lado do AVD no AVD Manager.
		9. Para executar o app no emulador dentro do Android Studio: selecione o dispositivo no seletor de dispositivos (toolbar) e clique no botão **Run** (triângulo verde) ou use `Shift+F10`.

		Dicas/observações no Android Studio:
		- Se houver problemas de performance, instale/ative o acelerador HAXM (Intel HAXM) ou ative o Windows Hypervisor Platform/Hyper-V conforme a sua plataforma: `Tools > SDK Manager > SDK Tools` e habilite `Intel x86 Emulator Accelerator (HAXM installer)` ou use as opções de virtualização do Windows.
		- Caso a imagem do sistema não esteja listada, abra `Tools > SDK Manager` e, na aba `SDK Platforms`, instale a plataforma Android correspondente; na aba `SDK Tools` instale `Android SDK Platform-Tools` e `Android Emulator`.
		- Após o emulador estar rodando, você pode executar o app pelo terminal com `flutter run` ou pelo Android Studio como descrito acima.

	- Depois de iniciado o emulador, verifique o id com:

		```powershell
		flutter devices
		```

	- Execute o app no emulador (exemplo de id `emulator-5554`):

		```powershell
		flutter run -d emulator-5554
		```

	- Observações importantes:
		- Ative virtualização no BIOS/UEFI e instale aceleradores (HAXM ou usar Hyper-V/Windows Hypervisor Platform) para melhor desempenho.
		- Se houver erros ao criar ou iniciar o AVD, abra o Android Studio > SDK Manager e instale as ferramentas `Android SDK Platform-Tools`, `Android SDK Tools`, e a imagem do sistema desejada.

- **Executando os testes**:

	- Testes Dart/Flutter:

		```powershell
		cd MesclaInvest
		flutter test
		```

	- Testes relacionados às funções (se existirem scripts):

		```powershell
		cd MesclaInvest/functions
		npm test
		```

## ✅ Observações finais

- O arquivo de configuração do Firebase para o app está em `lib/firebase_options.dart` — se precisar substituir por outro projeto Firebase, gere e atualize esse arquivo conforme a documentação do FlutterFire.
- Para mais detalhes sobre configuração específica de Android/iOS consulte as pastas `android/` e `ios/` dentro de `MesclaInvest`.
- Para executar todos os testes de functions com os emuladores ativos, use:

	```powershell
	cd MesclaInvest
	flutter test --dart-define=RUN_FIREBASE_FUNCTIONS_TESTS=true
	```

	Se quiser rodar apenas um arquivo específico, use o padrão novo `*_test.dart`, por exemplo:

	```powershell
	flutter test test/addUser_test.dart --dart-define=RUN_FIREBASE_FUNCTIONS_TESTS=true
	```
