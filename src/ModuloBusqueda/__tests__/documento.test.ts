import request from 'supertest';
import { app, Metadato } from '../index';
import { mockDoc } from './helpers';

describe('GET /documento/:id', () => {
  let findOneSpy: jest.SpyInstance;

  beforeEach(() => {
    findOneSpy = jest.spyOn(Metadato, 'findOne').mockResolvedValue(null as never);
  });

  it('sin par\u00e1metro id_empresa \u2192 400', async () => {
    const res = await request(app).get('/documento/42');

    expect(res.status).toBe(400);
    expect(res.body.success).toBe(false);
    expect(res.body.mensaje).toMatch(/id_empresa/i);
  });

  it('id num\u00e9rico \u2192 busca por id_documento_sql con estatus:true y id_empresa', async () => {
    findOneSpy.mockResolvedValue(mockDoc({ id_documento_sql: 42 }) as never);

    const res = await request(app).get('/documento/42').query({ id_empresa: 1 });

    expect(res.status).toBe(200);
    expect(findOneSpy).toHaveBeenCalledWith({ id_documento_sql: 42, id_empresa: 1, estatus: true });
  });

  it('id alfanum\u00e9rico \u2192 busca por codigo_interno con estatus:true y id_empresa', async () => {
    findOneSpy.mockResolvedValue(mockDoc({ codigo_interno: 'CAL-MAN-001' }) as never);

    const res = await request(app).get('/documento/CAL-MAN-001').query({ id_empresa: 1 });

    expect(res.status).toBe(200);
    expect(findOneSpy).toHaveBeenCalledWith({ codigo_interno: 'CAL-MAN-001', id_empresa: 1, estatus: true });
  });

  it('documento encontrado \u2192 200 con { success: true, data }', async () => {
    findOneSpy.mockResolvedValue(mockDoc() as never);

    const res = await request(app).get('/documento/1').query({ id_empresa: 1 });

    expect(res.status).toBe(200);
    expect(res.body.success).toBe(true);
    expect(res.body.data).toBeDefined();
  });

  it('documento no encontrado (findOne retorna null) \u2192 404', async () => {
    findOneSpy.mockResolvedValue(null as never);

    const res = await request(app).get('/documento/999').query({ id_empresa: 1 });

    expect(res.status).toBe(404);
    expect(res.body.success).toBe(false);
    expect(res.body.mensaje).toMatch(/no se encontr\u00f3/i);
  });

  it('documento con estatus:false invisible (filtro de borrado l\u00f3gico) \u2192 404', async () => {
    findOneSpy.mockResolvedValue(null as never);

    const res = await request(app).get('/documento/CAL-MAN-BORRADO').query({ id_empresa: 1 });

    expect(res.status).toBe(404);
    const filtro = findOneSpy.mock.calls[0]?.[0] as Record<string, unknown>;
    expect(filtro['estatus']).toBe(true);
    expect(filtro['id_empresa']).toBe(1);
  });

  it('error de base de datos \u2192 500', async () => {
    findOneSpy.mockRejectedValue(new Error('MongoDB no disponible'));

    const res = await request(app).get('/documento/1').query({ id_empresa: 1 });

    expect(res.status).toBe(500);
    expect(res.body.success).toBe(false);
    expect(res.body.mensaje).toMatch(/error/i);
  });

  it('id con letras y n\u00fameros (alfanum\u00e9rico) no se trata como num\u00e9rico', async () => {
    findOneSpy.mockResolvedValue(mockDoc() as never);

    await request(app).get('/documento/DOC-123').query({ id_empresa: 1 });

    const filtro = findOneSpy.mock.calls[0]?.[0] as Record<string, unknown>;
    expect(filtro).toHaveProperty('codigo_interno', 'DOC-123');
    expect(filtro).toHaveProperty('id_empresa', 1);
    expect(filtro).not.toHaveProperty('id_documento_sql');
  });
});

describe('DELETE /documento/:id', () => {
  let findOneSpy: jest.SpyInstance;
  let saveSpy:    jest.SpyInstance;

  beforeEach(() => {
    findOneSpy = jest.spyOn(Metadato, 'findOne').mockResolvedValue(null as never);
  });

  it('sin par\u00e1metro id_empresa \u2192 400', async () => {
    const res = await request(app).delete('/documento/42');

    expect(res.status).toBe(400);
    expect(res.body.success).toBe(false);
    expect(res.body.mensaje).toMatch(/id_empresa/i);
  });

  it('documento no encontrado en el tenant \u2192 404', async () => {
    const res = await request(app).delete('/documento/999').query({ id_empresa: 1 });

    expect(res.status).toBe(404);
    expect(res.body.success).toBe(false);
  });

  it('el filtro de b\u00fasqueda incluye id_empresa (aislamiento cross-tenant)', async () => {
    await request(app).delete('/documento/42').query({ id_empresa: 2 });

    const filtro = findOneSpy.mock.calls[0]?.[0] as Record<string, unknown>;
    expect(filtro).toHaveProperty('id_empresa', 2);
    expect(filtro).toHaveProperty('id_documento_sql', 42);
  });

  it('borrado l\u00f3gico exitoso \u2192 200', async () => {
    const docMock = { ...mockDoc(), estatus: true, fecha_eliminacion: null, save: jest.fn().mockResolvedValue(undefined) };
    findOneSpy.mockResolvedValue(docMock as never);

    const res = await request(app).delete('/documento/1').query({ id_empresa: 1 });

    expect(res.status).toBe(200);
    expect(res.body.success).toBe(true);
    expect(docMock.estatus).toBe(false);
    expect(docMock.fecha_eliminacion).toBeInstanceOf(Date);
  });
});
