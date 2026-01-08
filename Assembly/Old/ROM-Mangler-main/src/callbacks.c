// What a tangled mess this is

#include <stdio.h>
#include <stdlib.h>
#include "callbacks.h" 
#include "resource.h"

char sourceFilename[MAX_PATH*32] = ""; // *32 for 32 files 
char destFilename[MAX_PATH] = "";
char destSplit[MAX_PATH] = "";
int romSize = 0, fileIndex;
int oddevenState = 0;

void WriteSplit (HWND hwnd, int fileSize, unsigned char *romBuffer)
{
	int i, d, e;
	char destSplit[MAX_PATH] = "";
	unsigned char *romPointer = romBuffer;
	HANDLE wFile;
	DWORD dwWrite;
	char drive[3], dir[256], fname[256], ext[256];
	int oddevenSwitch = 0;
	char *destBuffer = NULL;

	// Split the file name up to be recombined as filename.xx.ext
	_splitpath(destFilename, drive, dir, fname, ext);
	// Count 0 to n for each file to create
	for (i=0; i < (fileSize/romSize); i++)
	{
		if (oddevenState)
		{
			oddevenSwitch = 0;
			while (1)	
			{
				// Split source to multiple odd/even files
				if (oddevenSwitch)
				{
					sprintf (destSplit, "%s%s%s.%02i.EVEN%s", drive, dir, fname, fileIndex++, ext);
					d = 1;
				}
				else
				{
					sprintf (destSplit, "%s%s%s.%02i.ODD%s", drive, dir, fname, fileIndex, ext);
					d = 0;
				}
				
				destBuffer = GlobalAlloc(LMEM_FIXED, romSize);
				e = 0;
				while (e < romSize)
				{
					destBuffer[e++] = romBuffer[d];
					d += 2;
				}
				
				wFile =  CreateFile(destSplit, GENERIC_WRITE, 0, NULL, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL);
				if (wFile == INVALID_HANDLE_VALUE)
					MessageBox (hwnd, "Unable to open destination file", "File Error", MB_ICONEXCLAMATION | MB_OK);
				else
				{
					dwWrite = 0;
					WriteFile (wFile, destBuffer, romSize, &dwWrite, NULL);
				}
				CloseHandle (wFile);
				
				GlobalFree(destBuffer);
				
				if (oddevenSwitch) break;
				oddevenSwitch = !oddevenSwitch;
			}
		}
		else
		{	
			// Split source to multiple files
			sprintf (destSplit, "%s%s%s.%02i%s", drive, dir, fname, fileIndex++, ext);
			wFile =  CreateFile(destSplit, GENERIC_WRITE, 0, NULL, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL);
			if (wFile == INVALID_HANDLE_VALUE)
				MessageBox (hwnd, "Unable to open destination file", "File Error", MB_ICONEXCLAMATION | MB_OK);
			else
			{
				dwWrite = 0;
				WriteFile (wFile, &romPointer[i*romSize], romSize, &dwWrite, NULL);
			}
			CloseHandle (wFile);
		}
		
		
	}
}

void WriteRepeat (HWND hwnd, int fileSize, unsigned char *romBuffer)
{
	DWORD dwWrite;
	HANDLE wFile;
	int i, d, e;
	char drive[3], dir[256], fname[256], ext[256];
	int oddevenSwitch = 0;
	char *destBuffer = NULL;
	
	if (oddevenState)
	{
		_splitpath(destFilename, drive, dir, fname, ext);
		while (1)
		{
			// Split source to odd and even file
			if (oddevenSwitch)
			{
				sprintf (destSplit, "%s%s%s.EVEN%s", drive, dir, fname, ext);
				d = 1;
			}
			else
			{
				sprintf (destSplit, "%s%s%s.ODD%s", drive, dir, fname, ext);
				d = 0;
			}
			
			destBuffer = GlobalAlloc(LMEM_FIXED, romSize);
			e = 0;
			while (e < romSize)
			{
				destBuffer[e++] = romBuffer[d];
				d += 2;
			}
			
			wFile =  CreateFile(destSplit, GENERIC_WRITE, 0, NULL, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL);
			if (wFile == INVALID_HANDLE_VALUE)
				MessageBox (hwnd, "Unable to open destination file", "File Error", MB_ICONEXCLAMATION | MB_OK);
			else
			{
				dwWrite = 0;
				WriteFile (wFile, destBuffer, romSize, &dwWrite, NULL);
			}
			CloseHandle (wFile);
			
			GlobalFree(destBuffer);
			
			if (oddevenSwitch) break;
			oddevenSwitch = !oddevenSwitch;
		}
	}
	else
	{
		wFile = CreateFile(destFilename, GENERIC_WRITE, 0, NULL, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL);
		if(wFile == INVALID_HANDLE_VALUE)
		{
			MessageBox (hwnd, "Unable to open destination file", "File Error", MB_ICONEXCLAMATION | MB_OK);
		}
		else
		{
			for (i=0; i<romSize; i+=fileSize)
			{
				dwWrite = 0;
				WriteFile (wFile, romBuffer, fileSize, &dwWrite, NULL);
			}
		}
		CloseHandle (wFile);
	}
}

void ProcessFiles (HWND hwnd)
{
	DWORD fileSize, firstFileSize, dwRead;
	unsigned char *romBuffer;
	int totalSize = 0;
	int len, i;
	HANDLE rFile;
	char errorMsg[32];
	
	// I hate reading everything into RAM but it's the most reliable way to do this
	romBuffer = GlobalAlloc(LMEM_FIXED, 4*1024*1024);
	// Index of current file to write as a split file
	fileIndex = 0;
	// Get filename from destination text box
	len = GetWindowTextLength(GetDlgItem(hwnd, IDT_DEST));
	GetDlgItemText(hwnd, IDT_DEST, destFilename, len+1);
	// Open destination file
	
	// Count through all fileds, ignoring empty ones, loading files to romBuffer
	for (i=0; i<32; i++)
	{			
		// Get filenames from input boxes
		len = GetWindowTextLength(GetDlgItem(hwnd, IDT_SOURCE00+i));
		if (len == 0) continue;
		GetDlgItemText(hwnd, IDT_SOURCE00+i, sourceFilename, len+1);
	
		rFile = CreateFile(sourceFilename, GENERIC_READ, FILE_SHARE_READ, NULL, OPEN_EXISTING, 0, NULL);
		if (rFile == INVALID_HANDLE_VALUE)
		{
			sprintf (errorMsg, "Error opening file %i", i+1);
			MessageBox (hwnd, errorMsg, "File Error", MB_ICONEXCLAMATION | MB_OK);
		}
		else
		{
			fileSize = GetFileSize(rFile, NULL);
			dwRead = 0;
			if (ReadFile(rFile, &romBuffer[totalSize], fileSize, &dwRead, NULL))
			{
				totalSize += fileSize;
			}
			else
			{
				sprintf (errorMsg, "Error reading file %i", i+1);
				MessageBox (hwnd, errorMsg , "File Error", MB_ICONEXCLAMATION | MB_OK);
				CloseHandle(rFile);
				break;
			}
			if (totalSize > 4*1024*1024)
			{
				MessageBox (hwnd, "Total capacity greater than 4MB", "Too big" , MB_ICONEXCLAMATION | MB_OK);
				break;
			}
		}
		CloseHandle(rFile);
	}

	// Divide totalSize by 2 if using odd/even split	
	if (oddevenState) totalSize /= 2;
	
	if (totalSize > romSize)
	{
		WriteSplit (hwnd, totalSize, romBuffer);
	}
	else
	{
		WriteRepeat (hwnd, totalSize, romBuffer);
	}
	GlobalFree(romBuffer);
}

BOOL CALLBACK DlgProc(HWND hwnd, UINT Message, WPARAM wParam, LPARAM lParam)
{
	switch(Message)
	{
		case WM_INITDIALOG:

			break;
		case WM_COMMAND:
			 switch(LOWORD(wParam))
			 {
				case IDR_1KB:
					romSize = 1024;
					break;
				case IDR_2KB:
					romSize = 2048;
					break;
				case IDR_4KB:
					romSize = 4096;
					break;
				case IDR_8KB:
					romSize = 8192;
					break;
				case IDR_16KB:
					romSize = 16384;
					break;
				case IDR_32KB:
					romSize = 32768;
					break;
				case IDR_64KB:
					romSize = 65536;
					break;
				case IDR_128KB:
					romSize = 131072;
					break;
				case IDR_256KB:
					romSize = 262144;
					break;
				case IDR_512KB:
					romSize = 524288;
					break;
			
				case IDC_SOURCE00:
				case IDC_SOURCE01:
				case IDC_SOURCE02:
				case IDC_SOURCE03:
				case IDC_SOURCE04:
				case IDC_SOURCE05:
				case IDC_SOURCE06:
				case IDC_SOURCE07:
				case IDC_SOURCE08:
				case IDC_SOURCE09:
				case IDC_SOURCE10:
				case IDC_SOURCE11:
				case IDC_SOURCE12:
				case IDC_SOURCE13:
				case IDC_SOURCE14:
				case IDC_SOURCE15:
				case IDC_SOURCE16:
				case IDC_SOURCE17:
				case IDC_SOURCE18:
				case IDC_SOURCE19:
				case IDC_SOURCE20:
				case IDC_SOURCE21:
				case IDC_SOURCE22:
				case IDC_SOURCE23:
				case IDC_SOURCE24:
				case IDC_SOURCE25:
				case IDC_SOURCE26:
				case IDC_SOURCE27:
				case IDC_SOURCE28:
				case IDC_SOURCE29:
				case IDC_SOURCE30:
				case IDC_SOURCE31:
				{
					OPENFILENAME ofn;
					ZeroMemory(&ofn, sizeof(ofn));
					ofn.lStructSize = sizeof(ofn);
					ofn.hwndOwner = hwnd;
					ofn.lpstrFilter = "Binary Files (*.bin)\0*.bin\0ROM Files (*.rom)\0*.rom\0All Files (*.*)\0*.*\0";
					ofn.lpstrFile = sourceFilename;
					ofn.nMaxFile = MAX_PATH;
					ofn.Flags = OFN_EXPLORER | OFN_FILEMUSTEXIST | OFN_HIDEREADONLY | OFN_ALLOWMULTISELECT;
					ofn.lpstrDefExt = "bin";
					
					int i;
					if(GetOpenFileName(&ofn))
					{
						// Write loaded filename to correct text box
						SetDlgItemText(hwnd, (IDT_SOURCE00 - IDC_SOURCE00) + LOWORD(wParam) , sourceFilename);
					}
				}
				break;
				
				case IDC_DEST:
				{
					OPENFILENAME ofn;
					ZeroMemory(&ofn, sizeof(ofn));
					ofn.lStructSize = sizeof(ofn);
					ofn.hwndOwner = hwnd;
					ofn.lpstrFilter = "Binary Files (*.bin)\0*.bin\0ROM Files (*.rom)\0*.rom\0All Files (*.*)\0*.*\0";
					ofn.lpstrFile = destFilename;
					ofn.nMaxFile = MAX_PATH;
					ofn.Flags = OFN_EXPLORER | OFN_HIDEREADONLY;
					ofn.lpstrDefExt = "bin";
					if(GetSaveFileName(&ofn))
					{
						SetDlgItemText(hwnd, IDT_DEST, destFilename);
					}
				}
				break;
				
				case IDC_WRITE:
				{
					if (romSize == 0)
						MessageBox (hwnd, "Please specify a ROM size", "Unspecified", MB_ICONEXCLAMATION | MB_OK);
					else
					{
						ProcessFiles(hwnd);
					}
				}
				break;
				
				case IDC_SPLIT:
				{
					oddevenState = !oddevenState;
					CheckDlgButton (hwnd, IDC_SPLIT, oddevenState);
				}
				
			 }
			 break;
		case WM_CLOSE:
			EndDialog(hwnd, 0);
			break;
		default:
			return FALSE;
	}
	return TRUE;
}
