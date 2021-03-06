#Copyright (c) 2014 Serguei Kouzmine
#
#Permission is hereby granted, free of charge, to any person obtaining a copy
#of this software and associated documentation files (the "Software"), to deal
#in the Software without restriction, including without limitation the rights
#to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#copies of the Software, and to permit persons to whom the Software is
#furnished to do so, subject to the following conditions:
#
#The above copyright notice and this permission notice shall be included in
#all copies or substantial portions of the Software.
#
#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
#THE SOFTWARE.
param(
  [string]$browser = 'chrome',
  [switch]$pause
)


[void][System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')

$MODULE_NAME = 'selenium_utils.psd1'
Import-Module -Name ('{0}/{1}' -f '.',$MODULE_NAME)

$selenium = launch_selenium -browser $browser

[void]$selenium.Manage().timeouts().ImplicitlyWait([System.TimeSpan]::FromSeconds(60))

$selenium.url = $base_url = 'http://translation2.paralink.com'
$selenium.Navigate().GoToUrl(($base_url + '/'))

[string]$text = 'Spanish-Russian translation'
[string]$top_frame_xpath = "//frame[@id='topfr']"
[object]$top_frame = $null
$top_frame = find_element_new -xpath $top_frame_xpath
$current_frame = $selenium.SwitchTo().Frame($top_frame)
[NUnit.Framework.Assert]::AreEqual($current_frame.url,('{0}/{1}' -f $base_url,'newtop.asp'),$current_frame.url)
Write-Debug ('Switched to {0} {1}' -f $current_frame.url,$top_frame_xpath)
$top_frame = $null

$css_selector = 'select#directions > option[value="es/ru"]'
[OpenQA.Selenium.IWebElement]$element = $null

$element = find_element_new -css $css_selector
[NUnit.Framework.Assert]::AreEqual($text,$element.Text,$element.Text)
$element.Click()
$element = $null

custom_pause

[string]$xpath2 = "//textarea[@id='source']"

[OpenQA.Selenium.IWebElement]$element = $null
find_page_element_by_xpath ([ref]$current_frame) ([ref]$element) $xpath2
# TODO: modify  the method to accept current_frame 
# $element = find_element_new -xpath $xpath2

highlight ([ref]$current_frame) ([ref]$element)
[OpenQA.Selenium.Interactions.Actions]$actions = New-Object OpenQA.Selenium.Interactions.Actions ($current_frame)
$actions.MoveToElement([OpenQA.Selenium.IWebElement]$element).Click().Build().Perform()

$text = @"
En un lugar de la Mancha, de cuyo nombre no quiero acordarme, no ha mucho 
tiempo que vivía un hidalgo de los de lanza en astillero, adarga antigua, rocín flaco 
y galgo corredor. Una olla de algo más vaca que carnero, salpicón las más noches, 
duelos y quebrantos los sábados, lentejas 
los viernes, algún palomino de añadidura 
los domingos, consumían las tres partes de
 su hacienda.
"@
[void]$element.SendKeys($text)
$element = $null

Start-Sleep -Milliseconds 1000
$css_selector = 'img[src*="btn-en-tran.gif"]'


find_page_element_by_css_selector ([ref]$current_frame) ([ref]$element) $css_selector
# TODO: modify  the method to accept current_frame 
# $element = find_element_new -css $css_selector

[NUnit.Framework.Assert]::AreEqual('Translate',$element.GetAttribute('title'),$element.GetAttribute('title'))
highlight ([ref]$current_frame) ([ref]$element)
[OpenQA.Selenium.Interactions.Actions]$actions = New-Object OpenQA.Selenium.Interactions.Actions ($current_frame)
$actions.MoveToElement([OpenQA.Selenium.IWebElement]$element).Click().Build().Perform()

$element = $null
custom_pause

[void]$selenium.SwitchTo().DefaultContent()

[string]$bot_frame_xpath = "//frame[@id='botfr']"
[object]$bot_frame = $null
$bot_frame = find_element_new -xpath $bot_frame_xpath
$current_frame = $selenium.SwitchTo().Frame($bot_frame)
[NUnit.Framework.Assert]::AreEqual($current_frame.url,('{0}/{1}' -f $base_url,'newbot.asp'),$current_frame.url)
Write-Debug ('Switched to {0}' -f $current_frame.url)
$bot_frame = $null

[string]$xpath2 = "//textarea[@id='target']"

[OpenQA.Selenium.IWebElement]$element = $null
find_page_element_by_xpath ([ref]$current_frame) ([ref]$element) $xpath2
# TODO: modify  the method to accept current_frame 
# $current_frame = find_element_new -xpath $current_frame_xpath

highlight ([ref]$current_frame) ([ref]$element)
Write-Output $element.Text

custom_pause

#
# https://code.google.com/p/selenium/source/browse/java/client/src/org/openqa/selenium/remote/HttpCommandExecutor.java?r=3f4622ced689d2670851b74dac0c556bcae2d0fe
# write-output $frame.PageSource
[void]$selenium.SwitchTo().DefaultContent()

$current_frame = $selenium.SwitchTo().Frame(1)
[NUnit.Framework.Assert]::AreEqual($current_frame.url,('{0}/{1}' -f $base_url,'newbot.asp'),$current_frame.url)

custom_pause

[void]$selenium.SwitchTo().DefaultContent()
$current_frame = $selenium.SwitchTo().Frame(0)
[NUnit.Framework.Assert]::AreEqual($current_frame.url,('{0}/{1}' -f $base_url,'newtop.asp'),$current_frame.url)
Write-Debug ('Switched to {0}' -f $current_frame.url)
[bool]$fullstop = [bool]$PSBoundParameters['pause'].IsPresent
custom_pause -fullstop $fullstop

[void]$selenium.SwitchTo().DefaultContent()
Write-Debug ('Switched to {0}' -f $selenium.url)

# TODO:
# [void]$selenium.SwitchOutOfIFrame()

# Cleanup
cleanup ([ref]$selenium)
