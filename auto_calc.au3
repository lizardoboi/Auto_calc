#include <ButtonConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <Date.au3>

Global $sLogFilePath = "c:\syadm_lab2\log.txt" ; Путь к файлу журнала

Global $sComputerName = @ComputerName ; Получение имени компьютера
Global $sStartDate = _Now() ; Получение текущей даты и времени

Global $hGUI = GUICreate("Авт0-кальк", 400, 200) ; Создание главного окна
GUISetState(@SW_SHOW) ; Отображение главного окна

Global $sGroupInfo = "Группа: АВТ-141 | Вариант: 2" ; Информация о группе и варианте
Global $sAuthor = "Фамилия: Послов" ; Информация об авторе

GUICtrlCreateLabel($sGroupInfo, 10, 10, 380, 20) ; Создание метки для отображения информации о группе и варианте
GUICtrlCreateLabel($sAuthor, 10, 30, 380, 20) ; Создание метки для отображения информации об авторе

Global $hEditBox = GUICtrlCreateEdit("", 10, 90, 280, 100) ; Создание редактируемого поля для ввода выражения
GUICtrlSetLimit($hEditBox, 100) ; Ограничение длины текста в редактируемом поле до 100 символов

Global $hCalcButton = GUICtrlCreateButton("Калькулировать", 300, 90, 100, 30) ; Создание кнопки "Калькулировать"
Global $hExitButton = GUICtrlCreateButton("Выход (60с)", 300, 130, 80, 30) ; Создание кнопки "Выход (60с)"

Global $iSecondsRemaining = 60 ; Начальное количество секунд для таймера
Global $iTimer = TimerInit() ; Инициализация таймера
Global $sExpression = "" ; Переменная для хранения выражения

While 1
    If TimerDiff($iTimer) >= 1000 Then
        $iSecondsRemaining -= 1 ; Уменьшаем количество оставшихся секунд на одну
        If $iSecondsRemaining <= 0 Then
            ExitProgram("Закрыто автоматически") ; Если время истекло, закрываем программу
        EndIf
        GUICtrlSetData($hExitButton, "Выход (" & $iSecondsRemaining & "с)") ; Обновляем текст на кнопке выхода
        $iTimer = TimerInit() ; Сбрасываем таймер
    EndIf

    $msg = GUIGetMsg() ; Получаем сообщение от GUI
    Switch $msg
        Case $GUI_EVENT_CLOSE
            ExitProgram("Закрыто юзером") ; Если пользователь закрыл программу, завершаем выполнение
        Case $hCalcButton
            $sExpression = GUICtrlRead($hEditBox) ; Получаем текст из редактируемого поля
            If $sExpression <> "" Then
			   $iTimer = TimerInit() ; Обновляем таймер при каждом действии пользователя
			   $iSecondsRemaining = 60 ; Сбрасываем количество оставшихся секунд
                Opt("SendKeyDownDelay", 20)

                ; Запускаем калькулятор Windows.
                Run("calc.exe")

                ; Ожидаем активации калькулятора с таймаутом 10 секунд.
                WinWaitActive("[CLASS:ApplicationFrameWindow]", "", 10)
                Sleep(1000)

                ; Если калькулятор не появился после 10 секунд, выходим из скрипта.
                If WinExists("[CLASS:ApplicationFrameWindow]") = 0 Then Exit

                ; Передаем каждый символ выражения в калькулятор.
                For $i = 1 To StringLen($sExpression)
                    $char = StringMid($sExpression, $i, 1)
                    If $char = "+" Then
                        Send("{+}")
                    ElseIf $char = "*" Then
                        Send("{*}")
                    Else
                        Send($char)
                    EndIf
                    ; Пауза после каждого символа, чтобы обеспечить правильный порядок ввода.
                    Sleep(50)
                Next

                ; Отправляем клавишу Enter в калькулятор
                ControlSend("[CLASS:ApplicationFrameWindow]", "", "Windows.UI.Core.CoreWindow1", '{ENTER}')
                Sleep(500)

                ; Убеждаемся, что окно активно, чтобы отправить ctrl+c для копирования результата в буфер обмена
                WinActivate("[CLASS:ApplicationFrameWindow]")
                Send("^c")
                LogInteraction("Калькулировано")
			 EndIf
		  Case $hExitButton
			LogInteraction("Выход")
            ExitProgram("Закрыто юзером")
    EndSwitch
WEnd

Func ExitProgram($sMessage)
    Local $sEndTime = _Now()
    FileWriteLine($sLogFilePath, "Имя компьютера: " & $sComputerName & " | Дата начала: " & $sStartDate & " | Дата конца: " & $sEndTime & " | Сообщение: " & $sMessage)
    Exit
EndFunc

Func LogInteraction($sInteraction)
    Local $sCurrentTime = _Now()
    FileWriteLine($sLogFilePath, "Взаимодействие: " & $sInteraction & " | Время: " & $sCurrentTime)
EndFunc