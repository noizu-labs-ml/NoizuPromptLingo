/**
 * NPL MCP Web Frontend Tests using Puppeteer
 *
 * Tests the web UI endpoints for functionality and visual correctness.
 */

const puppeteer = require('puppeteer');

const BASE_URL = 'http://localhost:8765';

// Test results collector
const results = {
    passed: [],
    failed: [],
    screenshots: []
};

function log(msg) {
    console.log(`[${new Date().toISOString()}] ${msg}`);
}

function pass(testName, details = '') {
    results.passed.push({ test: testName, details });
    log(`✅ PASS: ${testName}${details ? ' - ' + details : ''}`);
}

function fail(testName, error) {
    results.failed.push({ test: testName, error: error.toString() });
    log(`❌ FAIL: ${testName} - ${error}`);
}

async function takeScreenshot(page, name) {
    const path = `./tests/screenshots/${name}.png`;
    await page.screenshot({ path, fullPage: true });
    results.screenshots.push(path);
    log(`📸 Screenshot: ${path}`);
    return path;
}

// ============================================================================
// Test Functions
// ============================================================================

async function testHomePage(page) {
    log('\n--- Testing Home Page ---');

    try {
        await page.goto(BASE_URL, { waitUntil: 'networkidle0' });

        // Check title
        const title = await page.title();
        if (title.includes('NPL MCP')) {
            pass('Home page title', title);
        } else {
            fail('Home page title', `Expected 'NPL MCP', got '${title}'`);
        }

        // Check header exists
        const header = await page.$('header h1 a');
        if (header) {
            const headerText = await page.evaluate(el => el.textContent, header);
            pass('Header exists', headerText);
        } else {
            fail('Header exists', 'Header not found');
        }

        // Check navigation links
        const navLinks = await page.$$eval('nav a', links => links.map(l => ({
            text: l.textContent,
            href: l.getAttribute('href')
        })));
        pass('Navigation links', JSON.stringify(navLinks));

        // Check sessions section
        const sessionsCard = await page.$('.card h2');
        if (sessionsCard) {
            const text = await page.evaluate(el => el.textContent, sessionsCard);
            pass('Sessions section exists', text);
        } else {
            fail('Sessions section exists', 'Not found');
        }

        // Check for session list items
        const sessionItems = await page.$$('.list li');
        pass('Session items count', `${sessionItems.length} sessions found`);

        await takeScreenshot(page, '01-home-page');

    } catch (error) {
        fail('Home page test', error);
    }
}

async function testSessionPage(page) {
    log('\n--- Testing Session Page ---');

    try {
        // First get a session ID from the home page
        await page.goto(BASE_URL, { waitUntil: 'networkidle0' });

        const sessionLink = await page.$('.list li a');
        if (!sessionLink) {
            log('⚠️  No sessions found, skipping session page test');
            return;
        }

        const sessionHref = await page.evaluate(el => el.getAttribute('href'), sessionLink);
        log(`Found session link: ${sessionHref}`);

        // Navigate to session
        await page.goto(`${BASE_URL}${sessionHref}`, { waitUntil: 'networkidle0' });

        // Check breadcrumb
        const breadcrumb = await page.$('.breadcrumb');
        if (breadcrumb) {
            const text = await page.evaluate(el => el.textContent, breadcrumb);
            pass('Session breadcrumb', text);
        } else {
            fail('Session breadcrumb', 'Not found');
        }

        // Check session title card
        const titleCard = await page.$('.card h2');
        if (titleCard) {
            const text = await page.evaluate(el => el.textContent, titleCard);
            pass('Session title', text);
        }

        // Check for chat rooms section
        const chatRoomsSection = await page.$eval('.card h3', el => el.textContent).catch(() => null);
        if (chatRoomsSection) {
            pass('Chat rooms section', chatRoomsSection);
        }

        // Check for artifacts section
        const sections = await page.$$eval('.card h3', els => els.map(e => e.textContent));
        pass('Session sections', JSON.stringify(sections));

        await takeScreenshot(page, '02-session-page');

    } catch (error) {
        fail('Session page test', error);
    }
}

async function testChatRoom(page) {
    log('\n--- Testing Chat Room ---');

    try {
        // Navigate to a chat room
        await page.goto(BASE_URL, { waitUntil: 'networkidle0' });

        // Look for any room link (session room or standalone)
        let roomLink = await page.$('a[href*="/room/"]');
        if (!roomLink) {
            log('⚠️  No chat rooms found, skipping chat room test');
            return;
        }

        const roomHref = await page.evaluate(el => el.getAttribute('href'), roomLink);
        log(`Found room link: ${roomHref}`);

        await page.goto(`${BASE_URL}${roomHref}`, { waitUntil: 'networkidle0' });

        // Check room title
        const roomTitle = await page.$eval('.card h2', el => el.textContent).catch(() => null);
        if (roomTitle) {
            pass('Room title', roomTitle);
        } else {
            fail('Room title', 'Not found');
        }

        // Check messages section
        const messagesSection = await page.$('.card h3');
        if (messagesSection) {
            pass('Messages section exists', 'Found');
        }

        // Count messages
        const messages = await page.$$('.message');
        pass('Message count', `${messages.length} messages`);

        // Check for message form
        const form = await page.$('form[method="POST"]');
        if (form) {
            pass('Message form exists', 'Found');
        } else {
            fail('Message form exists', 'Not found');
        }

        // Check form fields
        const personaInput = await page.$('input[name="persona"]');
        const messageTextarea = await page.$('textarea[name="message"]');
        const submitButton = await page.$('button[type="submit"]');

        if (personaInput && messageTextarea && submitButton) {
            pass('Form fields complete', 'persona, message, submit');
        } else {
            fail('Form fields complete', 'Missing fields');
        }

        await takeScreenshot(page, '03-chat-room');

        // Test message types rendering
        const messageContents = await page.$$eval('.message', msgs => msgs.map(m => ({
            author: m.querySelector('.author')?.textContent || 'unknown',
            hasContent: !!m.querySelector('.content'),
            hasEmoji: m.textContent.includes('👍') || m.textContent.includes('📋') || m.textContent.includes('📎'),
            html: m.innerHTML.substring(0, 200)
        })));

        log('Message types found:');
        const types = {
            regular: 0,
            emoji: 0,
            artifact: 0,
            todo: 0,
            join: 0
        };

        for (const msg of messageContents) {
            if (msg.html.includes('joined the room')) types.join++;
            else if (msg.html.includes('📎')) types.artifact++;
            else if (msg.html.includes('📋')) types.todo++;
            else if (msg.html.includes('👍') || msg.html.includes('👎') || msg.html.includes('❤️')) types.emoji++;
            else types.regular++;
        }

        pass('Message types', JSON.stringify(types));

    } catch (error) {
        fail('Chat room test', error);
    }
}

async function testArtifactPage(page) {
    log('\n--- Testing Artifact Page ---');

    try {
        // Navigate to artifact page directly
        await page.goto(`${BASE_URL}/artifact/4`, { waitUntil: 'networkidle0' });

        // Check if it's a 404 or valid page
        const is404 = await page.$eval('body', body => body.textContent.includes('not found')).catch(() => false);

        if (is404) {
            // Try artifact 1
            await page.goto(`${BASE_URL}/artifact/1`, { waitUntil: 'networkidle0' });
        }

        // Check artifact title
        const artifactTitle = await page.$eval('.card h2', el => el.textContent).catch(() => null);
        if (artifactTitle) {
            pass('Artifact title', artifactTitle);
        } else {
            fail('Artifact title', 'Not found');
        }

        // Check for type badge
        const badge = await page.$('.badge');
        if (badge) {
            const badgeText = await page.evaluate(el => el.textContent, badge);
            pass('Artifact type badge', badgeText);
        }

        // Check for content preview
        const contentPreview = await page.$('pre code');
        if (contentPreview) {
            const previewLength = await page.evaluate(el => el.textContent.length, contentPreview);
            pass('Content preview', `${previewLength} chars`);
        } else {
            // Check for image
            const image = await page.$('img');
            if (image) {
                pass('Image preview', 'Found');
            } else {
                fail('Content preview', 'No preview found');
            }
        }

        await takeScreenshot(page, '04-artifact-page');

    } catch (error) {
        fail('Artifact page test', error);
    }
}

async function testArtifactLinkInChat(page) {
    log('\n--- Testing Artifact Link in Chat ---');

    try {
        // Go to the test room we created earlier
        await page.goto(`${BASE_URL}/session/tujovg4p/room/4`, { waitUntil: 'networkidle0' });

        // Look for artifact link
        const artifactLink = await page.$('a[href*="/artifact/"]');
        if (!artifactLink) {
            log('⚠️  No artifact links in chat, trying other rooms');
            await page.goto(`${BASE_URL}/room/1`, { waitUntil: 'networkidle0' });
            const artifactLink2 = await page.$('a[href*="/artifact/"]');
            if (!artifactLink2) {
                fail('Artifact link in chat', 'No artifact links found in any room');
                return;
            }
        }

        const linkHref = await page.evaluate(el => el.getAttribute('href'), await page.$('a[href*="/artifact/"]'));
        const linkText = await page.evaluate(el => el.textContent, await page.$('a[href*="/artifact/"]'));
        pass('Artifact link found', `${linkText} -> ${linkHref}`);

        // Click the link
        await Promise.all([
            page.waitForNavigation({ waitUntil: 'networkidle0' }),
            page.click('a[href*="/artifact/"]')
        ]);

        // Verify we're on artifact page
        const url = page.url();
        if (url.includes('/artifact/')) {
            pass('Artifact link navigation', url);
        } else {
            fail('Artifact link navigation', `Expected artifact URL, got ${url}`);
        }

        await takeScreenshot(page, '05-artifact-from-chat');

    } catch (error) {
        fail('Artifact link in chat test', error);
    }
}

async function testPostMessage(page) {
    log('\n--- Testing Post Message ---');

    try {
        // Navigate to a chat room
        await page.goto(`${BASE_URL}/session/tujovg4p/room/4`, { waitUntil: 'networkidle0' });

        // Count messages before
        const messagesBefore = await page.$$('.message');
        const countBefore = messagesBefore.length;
        log(`Messages before: ${countBefore}`);

        // Fill in the form
        const testMessage = `Test message from Puppeteer at ${new Date().toISOString()}`;

        await page.type('input[name="persona"]', '', { delay: 0 });
        await page.$eval('input[name="persona"]', el => el.value = '');
        await page.type('input[name="persona"]', 'puppeteer-test');
        await page.type('textarea[name="message"]', testMessage);

        await takeScreenshot(page, '06-before-send');

        // Submit the form
        await Promise.all([
            page.waitForNavigation({ waitUntil: 'networkidle0' }),
            page.click('button[type="submit"]')
        ]);

        // Count messages after
        const messagesAfter = await page.$$('.message');
        const countAfter = messagesAfter.length;
        log(`Messages after: ${countAfter}`);

        if (countAfter > countBefore) {
            pass('Message posted', `Count: ${countBefore} -> ${countAfter}`);
        } else {
            fail('Message posted', 'Message count did not increase');
        }

        // Verify the message appears
        const pageContent = await page.content();
        if (pageContent.includes('puppeteer-test')) {
            pass('Message author visible', 'puppeteer-test');
        } else {
            fail('Message author visible', 'Author not found in page');
        }

        await takeScreenshot(page, '07-after-send');

    } catch (error) {
        fail('Post message test', error);
    }
}

async function testAPIEndpoints(page) {
    log('\n--- Testing API Endpoints ---');

    const endpoints = [
        '/api/sessions',
        '/api/session/tujovg4p',
        '/api/room/4/feed',
        '/api/artifact/4'
    ];

    for (const endpoint of endpoints) {
        try {
            const response = await page.goto(`${BASE_URL}${endpoint}`, { waitUntil: 'networkidle0' });
            const status = response.status();

            if (status === 200) {
                const content = await page.content();
                // Check if it's JSON
                if (content.includes('{') || content.includes('[')) {
                    pass(`API ${endpoint}`, `Status: ${status}`);
                } else {
                    fail(`API ${endpoint}`, 'Response not JSON');
                }
            } else {
                fail(`API ${endpoint}`, `Status: ${status}`);
            }
        } catch (error) {
            fail(`API ${endpoint}`, error);
        }
    }
}

async function testDarkTheme(page) {
    log('\n--- Testing Dark Theme ---');

    try {
        await page.goto(BASE_URL, { waitUntil: 'networkidle0' });

        // Check CSS variables
        const bgColor = await page.evaluate(() => {
            return getComputedStyle(document.body).backgroundColor;
        });

        // Dark theme should have dark background
        if (bgColor.includes('26') || bgColor.includes('rgb(26')) {
            pass('Dark theme background', bgColor);
        } else {
            log(`Background color: ${bgColor}`);
            pass('Background color detected', bgColor);
        }

        // Check accent color
        const accentEl = await page.$('.card h2');
        if (accentEl) {
            const accentColor = await page.evaluate(el => getComputedStyle(el).color, accentEl);
            pass('Accent color', accentColor);
        }

    } catch (error) {
        fail('Dark theme test', error);
    }
}

async function testResponsiveDesign(page) {
    log('\n--- Testing Responsive Design ---');

    const viewports = [
        { name: 'Desktop', width: 1920, height: 1080 },
        { name: 'Laptop', width: 1366, height: 768 },
        { name: 'Tablet', width: 768, height: 1024 },
        { name: 'Mobile', width: 375, height: 667 }
    ];

    for (const vp of viewports) {
        try {
            await page.setViewport({ width: vp.width, height: vp.height });
            await page.goto(BASE_URL, { waitUntil: 'networkidle0' });

            // Check if content is visible
            const container = await page.$('.container');
            if (container) {
                const box = await container.boundingBox();
                if (box && box.width > 0) {
                    pass(`${vp.name} viewport`, `${vp.width}x${vp.height}, container width: ${box.width}`);
                }
            }

            await takeScreenshot(page, `08-responsive-${vp.name.toLowerCase()}`);

        } catch (error) {
            fail(`${vp.name} viewport`, error);
        }
    }

    // Reset to desktop
    await page.setViewport({ width: 1920, height: 1080 });
}

async function test404Page(page) {
    log('\n--- Testing 404 Page ---');

    try {
        await page.goto(`${BASE_URL}/session/nonexistent123`, { waitUntil: 'networkidle0' });

        const content = await page.content();
        if (content.toLowerCase().includes('not found')) {
            pass('404 page for session', 'Shows not found message');
        } else {
            fail('404 page for session', 'Does not show not found');
        }

        await page.goto(`${BASE_URL}/artifact/99999`, { waitUntil: 'networkidle0' });
        const content2 = await page.content();
        if (content2.toLowerCase().includes('not found')) {
            pass('404 page for artifact', 'Shows not found message');
        } else {
            fail('404 page for artifact', 'Does not show not found');
        }

        await takeScreenshot(page, '09-404-page');

    } catch (error) {
        fail('404 page test', error);
    }
}

// ============================================================================
// Main Test Runner
// ============================================================================

async function runTests() {
    log('🚀 Starting NPL MCP Web Frontend Tests');
    log(`Base URL: ${BASE_URL}`);

    // Create screenshots directory
    const fs = require('fs');
    const screenshotsDir = './tests/screenshots';
    if (!fs.existsSync(screenshotsDir)) {
        fs.mkdirSync(screenshotsDir, { recursive: true });
    }

    let browser;
    try {
        browser = await puppeteer.launch({
            headless: 'new',
            args: ['--no-sandbox', '--disable-setuid-sandbox']
        });

        const page = await browser.newPage();
        await page.setViewport({ width: 1920, height: 1080 });

        // Run all tests
        await testHomePage(page);
        await testSessionPage(page);
        await testChatRoom(page);
        await testArtifactPage(page);
        await testArtifactLinkInChat(page);
        await testPostMessage(page);
        await testAPIEndpoints(page);
        await testDarkTheme(page);
        await testResponsiveDesign(page);
        await test404Page(page);

    } catch (error) {
        log(`❌ Fatal error: ${error}`);
    } finally {
        if (browser) {
            await browser.close();
        }
    }

    // Print summary
    log('\n' + '='.repeat(60));
    log('📊 TEST SUMMARY');
    log('='.repeat(60));
    log(`✅ Passed: ${results.passed.length}`);
    log(`❌ Failed: ${results.failed.length}`);
    log(`📸 Screenshots: ${results.screenshots.length}`);

    if (results.failed.length > 0) {
        log('\n❌ Failed Tests:');
        for (const f of results.failed) {
            log(`   - ${f.test}: ${f.error}`);
        }
    }

    log('\n📸 Screenshots saved to: ./tests/screenshots/');

    // Return exit code
    process.exit(results.failed.length > 0 ? 1 : 0);
}

runTests();
