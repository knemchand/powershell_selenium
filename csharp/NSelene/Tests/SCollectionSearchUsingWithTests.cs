﻿using NUnit.Framework;
using System;
using System.Linq;

using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Text.RegularExpressions;

using OpenQA.Selenium;
using OpenQA.Selenium.Interactions;
using OpenQA.Selenium.Support.UI;

// using static NSelene.Selene;
// Need 4.6
using NSelene;

namespace NSeleneTests
{
	[TestFixture]
	public class SCollectionSearchUsingWithTests: BaseTest
	{

		// [OneTimeSetUp]
		[SetUp]
		public void initPage()
		{
			// Given.RunFromAssemblyLocation = true;  
			// NOTE: the above would create a flash "Your file was not found"
			Given.OpenedPageWithBody(@"
                       <h1 name=""header"">Hello People!</h1>
                         <ul>Hello to:
                                      <li>Dear Bob</li>
                                      <li>Dear Frank</li>
                                      <li>Lovely Kate</li>
                          </ul>");
		}

		[Test]
		public void SCollectionSearchWithCss()
		{
			// search using wrapped driver methods	
			String cssSelector = "ul:nth-of-type(1) li";
			IWebDriver driver = Selene.GetWebDriver();
			ReadOnlyCollection<IWebElement> elements = driver.FindElements(By.CssSelector(cssSelector));
			Assert.NotNull(elements);

			// search thru NSelene
			SeleneCollection sElementCollection = Selene.SS(With.Css(cssSelector), driver);
			Assert.AreEqual(sElementCollection.Count, elements.Count);

		}

		[Test]
		public void SCollectionSearchUsingWithCssAndLegacy()
		{

			String cssSelector = "li";
			// compare with legacy search results
			ReadOnlyCollection <IWebElement> a = Selene.SS(With.Css(cssSelector)).ActualWebElements;
			ReadOnlyCollection <IWebElement> b = Selene.SS(cssSelector).ActualWebElements;
			Assert.AreEqual(a.Intersect(b).Count(), a.Count);
		}

		[Test]
		public void SeleneCollectionSearchWithXPath()
		{	
			// search using wrapped driver methods	
			IWebDriver driver = Selene.GetWebDriver();
			// confirm XPath is valid
			String xpath = "//ul/li";
			ReadOnlyCollection<IWebElement> webElements = driver.FindElements(By.XPath(xpath));
			Assert.NotNull(webElements);
			Assert.Greater(webElements.Count, 0);
			StringAssert.IsMatch("li", webElements[0].TagName);

			// search thru NSelene
			SeleneCollection seleWebElements = null;
			By seleneLocator = With.XPath(xpath);
			seleWebElements = Selene.SS(seleneLocator);
			Assert.NotNull(seleWebElements);
			Assert.AreEqual(seleWebElements.Count, webElements.Count);
			StringAssert.IsMatch("li", seleWebElements[0].TagName);
			// exercise NSelene extension methods
			Selene.SS(seleneLocator).Should(Have.CountAtLeast(1));
			Selene.SS(seleneLocator).Should(Have.ExactTexts("Dear Bob", "Dear Frank", "Lovely Kate"));
		}
		
		[Test]
		public void SEeleneCollectionSearchWithText()
		{
			String searchText = "Dear";
			String xpathTextSearch =
				String.Format("//*[contains(text(),'{0}')]" , searchText);

			// search using wrapped driver methods

			ReadOnlyCollection<IWebElement> webElements = Selene.GetWebDriver().FindElements(By.XPath(xpathTextSearch));
			Assert.NotNull(webElements);
			Assert.Greater(webElements.Count, 0);
			StringAssert.Contains(searchText, webElements[0].Text);


			// search thru NSelene
			By seleneLocator = NSelene.With.Text(searchText);
			IWebDriver webDriver = Selene.GetWebDriver();
			SeleneCollection seleWebElements = Selene.SS(seleneLocator);
			Assert.NotNull(seleWebElements);
			Assert.AreEqual(seleWebElements.Count, webElements.Count);
			StringAssert.Contains(searchText, seleWebElements[0].Text);


			// confirm all have searchText
			seleWebElements = Selene.SS(seleneLocator, webDriver);
			Assert.AreEqual(seleWebElements.FilterBy(Have.Text(searchText)).Count, seleWebElements.Count);				

			// exercise NSelene extension methods
			Selene.SS(seleneLocator).Should(Have.Texts("Bob", "Frank"));
			Selene.SS(seleneLocator).ShouldNot(Have.Texts("Bob"));
			Selene.SS(seleneLocator).ShouldNot(Have.Texts("Bob", "Kate", "Frank"));
			Selene.SS(seleneLocator).Should(Have.ExactTexts("Dear Bob", "Dear Frank"));
		}
	}
}
